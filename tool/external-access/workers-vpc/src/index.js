import {MOBILE_METADATA_CATALOG} from './metadata_catalog.js';
import {SIS_CHECKLIST_CATALOG} from './checklist_catalog.js';

const GLPI_ORIGIN = 'http://cau.ppiratini.intra.rs.gov.br';
const GLPI_API_PREFIX = '/sis/apirest.php';
const MOBILE_METADATA_PATH = '/metadata/mobile/sis/catalog';
const MOBILE_CHECKLIST_METADATA_PATH = '/metadata/mobile/sis/checklists';

const READ_ONLY_ITEM_PATTERN =
  /^\/(?:initSession|search\/Ticket|Ticket(?:\/\d+(?:\/(?:TicketFollowup|ITILSolution|Ticket_User|Group_Ticket|Document_Item|Document|Log))?)?|Document(?:\/\d+)?|Document_Item|ITILFollowup\/\d+\/Document_Item|ITILSolution\/\d+\/Document_Item|User(?:\/\d+)?|Group(?:\/\d+)?|Entity|Location|RequestType|ITILCategory|listSearchOptions\/Ticket|getFullSession|getActiveProfile|getMyProfiles|getMyEntities|PluginFormcreator(?:Form|Category|Section|Question|TargetTicket|Form_Profile|Form_Group)(?:\/\d+)?|search\/PluginGenericobjectConservacao|PluginGenericobjectConservacao(?:\/\d+)?)(?:$|[/?])/;

// Leituras de diretório (User/Group). O perfil helpdesk (Solicitante) não tem
// direito REST de ler User/Group — mas o formulário GLPI permite via dropdown
// de helpdesk. Para espelhar isso, esses GETs usam uma sessão de serviço
// elevada (token de serviço + perfil central), sem afetar a sessão do usuário.
const DIRECTORY_READ_PATTERN = /^\/(?:User|Group)(?:\/\d+)?(?:$|[/?])/;

const POST_ALLOWLIST = new Set([
  '/initSession',
  '/Ticket',
  '/TicketFollowup',
  '/ITILSolution',
  '/Ticket_User',
]);
const GET_ALLOWLIST = new Set(['/killSession']);
const SIS_ACTION_POST_PATTERNS = [
  /^\/(?:Ticket|ITILFollowup|ITILSolution)\/\d+\/Document(?:$|[/?])/,
];
const SIS_ACTION_PUT_PATTERN = /^\/(?:Ticket|ITILSolution)\/\d+(?:$|[/?])/;

const worker = {
  async fetch(request, env) {
    if (request.method === 'OPTIONS') {
      return withCors(new Response(null, { status: 204 }));
    }

    const incoming = new URL(request.url);
    if (incoming.pathname === '/healthz') {
      return withCors(new Response('ok', {
        status: 200,
        headers: {'Content-Type': 'text/plain; charset=utf-8'},
      }));
    }

    if (incoming.pathname === MOBILE_METADATA_PATH) {
      return metadataCatalogResponse(request);
    }

    if (incoming.pathname === MOBILE_CHECKLIST_METADATA_PATH) {
      return checklistCatalogResponse(request);
    }

    if (!env.GLPI) {
      return jsonError(500, 'SIS GLPI VPC binding is not configured.');
    }

    const glpiPath = normalizeGlpiPath(incoming.pathname);
    const apiPath = glpiPath.slice(GLPI_API_PREFIX.length) || '/';

    if (!isAllowedRequest(request.method, apiPath, env)) {
      return jsonError(403, 'Endpoint blocked by SIS Worker allowlist.');
    }

    const target = new URL(glpiPath + incoming.search, GLPI_ORIGIN);
    const headers = new Headers(request.headers);
    headers.delete('Host');
    const appToken = env.GLPI_APP_TOKEN;
    if (!appToken) {
      return jsonError(500, 'SIS GLPI App-Token is not configured.');
    }
    // GLPI accepts App-Token as a header or request parameter. Keep both so
    // Worker/VPC/header-casing quirks cannot regress the public mobile path.
    headers.set('App-Token', appToken);
    target.searchParams.set('app_token', appToken);

    const sendUpstream = (sessionTokenOverride) => {
      const upstreamHeaders = new Headers(headers);
      if (sessionTokenOverride) {
        upstreamHeaders.set('Session-Token', sessionTokenOverride);
      }
      return env.GLPI.fetch(new Request(target, {
        method: request.method,
        headers: upstreamHeaders,
        body: hasRequestBody(request.method) ? request.body : undefined,
        redirect: 'manual',
      }));
    };

    const useServiceSession =
      request.method === 'GET' &&
      DIRECTORY_READ_PATTERN.test(apiPath) &&
      Boolean(env.GLPI_SERVICE_USER_TOKEN);

    try {
      if (useServiceSession) {
        let token = await getServiceSession(env);
        let response = await sendUpstream(token);
        if (response.status === 401) {
          // Sessão de serviço expirou: renova uma vez e repete (GET sem body).
          token = await getServiceSession(env, true);
          response = await sendUpstream(token);
        }
        return withCors(response);
      }
      return withCors(await sendUpstream());
    } catch {
      return jsonError(502, 'SIS upstream unavailable through Workers VPC.');
    }
  },
};

export default worker;

// Sessão de serviço elevada (best-effort cache no isolate). Usada SOMENTE nos
// GETs de diretório (User/Group). Renova sob 401.
let serviceSessionToken = null;

async function getServiceSession(env, forceNew = false) {
  if (!forceNew && serviceSessionToken) {
    return serviceSessionToken;
  }
  serviceSessionToken = await acquireServiceSession(env);
  return serviceSessionToken;
}

async function acquireServiceSession(env) {
  const appToken = env.GLPI_APP_TOKEN;
  const initTarget = new URL(`${GLPI_API_PREFIX}/initSession`, GLPI_ORIGIN);
  initTarget.searchParams.set('app_token', appToken);
  const initResponse = await env.GLPI.fetch(new Request(initTarget, {
    method: 'GET',
    headers: new Headers({
      'App-Token': appToken,
      Authorization: `user_token ${env.GLPI_SERVICE_USER_TOKEN}`,
      Accept: 'application/json',
    }),
    redirect: 'manual',
  }));
  if (!initResponse.ok) {
    throw new Error('service session initSession failed');
  }
  const sessionToken = (await initResponse.json())?.session_token;
  if (!sessionToken) {
    throw new Error('service session token missing');
  }

  // Eleva para um perfil central (default Super-Admin=4) que tem direito de
  // ler User/Group. changeActiveProfile é uma chamada interna do Worker, fora
  // do allowlist público.
  const profileId = Number(env.GLPI_SERVICE_PROFILE_ID || '4');
  const profileTarget = new URL(`${GLPI_API_PREFIX}/changeActiveProfile`, GLPI_ORIGIN);
  profileTarget.searchParams.set('app_token', appToken);
  await env.GLPI.fetch(new Request(profileTarget, {
    method: 'POST',
    headers: new Headers({
      'App-Token': appToken,
      'Session-Token': sessionToken,
      'Content-Type': 'application/json',
      Accept: 'application/json',
    }),
    body: JSON.stringify({profiles_id: profileId}),
    redirect: 'manual',
  }));

  return sessionToken;
}

function normalizeGlpiPath(pathname) {
  if (pathname.startsWith(GLPI_API_PREFIX)) {
    return pathname;
  }
  if (pathname.startsWith('/apirest.php')) {
    return `/sis${pathname}`;
  }
  return `${GLPI_API_PREFIX}${pathname.startsWith('/') ? pathname : `/${pathname}`}`;
}

function isAllowedRequest(method, apiPath, env = {}) {
  if (method === 'GET') {
    return GET_ALLOWLIST.has(apiPath) || READ_ONLY_ITEM_PATTERN.test(apiPath);
  }
  if (method === 'POST') {
    if (POST_ALLOWLIST.has(apiPath) || SIS_ACTION_POST_PATTERNS.some((pattern) => pattern.test(apiPath))) {
      return true;
    }
    // Submissao FormCreator de checklist: bloqueada por padrao. So passa quando o
    // ambiente declara explicitamente ALLOW_FORMCREATOR_SUBMISSION=true.
    return (
      env.ALLOW_FORMCREATOR_SUBMISSION === 'true' &&
      apiPath === '/PluginFormcreatorFormAnswer'
    );
  }
  if (method === 'PUT') {
    return SIS_ACTION_PUT_PATTERN.test(apiPath);
  }
  return false;
}

export const __test = {
  fetch: (...args) => worker.fetch(...args),
  isAllowedRequest,
  normalizeGlpiPath,
  metadataCatalogResponse,
  checklistCatalogResponse,
};

function checklistCatalogResponse(request) {
  if (request.method !== 'GET' && request.method !== 'HEAD') {
    return jsonError(405, 'Checklist metadata catalog is read-only.');
  }

  const etag = quotedEtag(SIS_CHECKLIST_CATALOG.source_snapshot_sha256);
  if (request.headers.get('If-None-Match') === etag) {
    return withCors(new Response(null, {
      status: 304,
      headers: checklistMetadataHeaders(etag),
    }));
  }

  const body = JSON.stringify(SIS_CHECKLIST_CATALOG);
  return withCors(new Response(request.method === 'HEAD' ? null : body, {
    status: 200,
    headers: {
      ...checklistMetadataHeaders(etag),
      'Content-Type': 'application/json; charset=utf-8',
    },
  }));
}

function checklistMetadataHeaders(etag) {
  return {
    'Cache-Control': 'private, max-age=300',
    'ETag': etag,
    'X-GLPI-Snapshot-Hash': SIS_CHECKLIST_CATALOG.source_snapshot_sha256 || '',
  };
}

function metadataCatalogResponse(request) {
  if (request.method !== 'GET' && request.method !== 'HEAD') {
    return jsonError(405, 'Metadata catalog is read-only.');
  }

  const etag = quotedEtag(MOBILE_METADATA_CATALOG.etag);
  if (request.headers.get('If-None-Match') === etag) {
    return withCors(new Response(null, {
      status: 304,
      headers: metadataHeaders(etag),
    }));
  }

  const body = JSON.stringify(MOBILE_METADATA_CATALOG);
  return withCors(new Response(request.method === 'HEAD' ? null : body, {
    status: 200,
    headers: {
      ...metadataHeaders(etag),
      'Content-Type': 'application/json; charset=utf-8',
    },
  }));
}

function metadataHeaders(etag) {
  return {
    'Cache-Control': 'private, max-age=300',
    'ETag': etag,
    'X-GLPI-Snapshot-Hash': MOBILE_METADATA_CATALOG.source_snapshot_hash || '',
    'X-Consumer-Id': MOBILE_METADATA_CATALOG.consumer_id || '',
  };
}

function quotedEtag(value) {
  const raw = String(value || '');
  if (raw.startsWith('"') && raw.endsWith('"')) return raw;
  return `"${raw}"`;
}

function hasRequestBody(method) {
  return method !== 'GET' && method !== 'HEAD';
}

function jsonError(status, message) {
  return withCors(new Response(JSON.stringify({error: message}), {
    status,
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
    },
  }));
}

function withCors(response) {
  const headers = new Headers(response.headers);
  headers.set('Access-Control-Allow-Origin', '*');
  headers.set('Access-Control-Allow-Methods', 'GET, POST, PUT, OPTIONS');
  headers.set(
    'Access-Control-Allow-Headers',
    'Accept, Authorization, Content-Type, App-Token, Session-Token, If-None-Match',
  );
  headers.set('Access-Control-Expose-Headers', 'Content-Range, Accept-Range, ETag, X-GLPI-Snapshot-Hash, X-Consumer-Id');
  headers.set('Vary', 'Origin');
  return new Response(response.body, {
    status: response.status,
    statusText: response.statusText,
    headers,
  });
}
