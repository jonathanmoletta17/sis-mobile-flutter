import {MOBILE_METADATA_CATALOG} from './metadata_catalog.js';

const GLPI_ORIGIN = 'http://cau.ppiratini.intra.rs.gov.br';
const GLPI_API_PREFIX = '/sis/apirest.php';
const MOBILE_METADATA_PATH = '/metadata/mobile/sis/catalog';

const READ_ONLY_ITEM_PATTERN =
  /^\/(?:initSession|search\/Ticket|Ticket(?:\/\d+(?:\/(?:TicketFollowup|ITILSolution|Ticket_User|Group_Ticket|Document_Item|Document))?)?|Document(?:\/\d+)?|Document_Item|ITILFollowup\/\d+\/Document_Item|ITILSolution\/\d+\/Document_Item|User(?:\/\d+)?|Group(?:\/\d+)?|Entity|Location|RequestType|ITILCategory|listSearchOptions\/Ticket|getFullSession|getActiveProfile|getMyProfiles|getMyEntities)(?:$|[/?])/;

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

    if (!env.GLPI) {
      return jsonError(500, 'SIS GLPI VPC binding is not configured.');
    }

    const glpiPath = normalizeGlpiPath(incoming.pathname);
    const apiPath = glpiPath.slice(GLPI_API_PREFIX.length) || '/';

    if (!isAllowedRequest(request.method, apiPath)) {
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

    const upstreamRequest = new Request(target, {
      method: request.method,
      headers,
      body: hasRequestBody(request.method) ? request.body : undefined,
      redirect: 'manual',
    });

    try {
      return withCors(await env.GLPI.fetch(upstreamRequest));
    } catch {
      return jsonError(502, 'SIS upstream unavailable through Workers VPC.');
    }
  },
};

export default worker;

function normalizeGlpiPath(pathname) {
  if (pathname.startsWith(GLPI_API_PREFIX)) {
    return pathname;
  }
  if (pathname.startsWith('/apirest.php')) {
    return `/sis${pathname}`;
  }
  return `${GLPI_API_PREFIX}${pathname.startsWith('/') ? pathname : `/${pathname}`}`;
}

function isAllowedRequest(method, apiPath) {
  if (method === 'GET') {
    return GET_ALLOWLIST.has(apiPath) || READ_ONLY_ITEM_PATTERN.test(apiPath);
  }
  if (method === 'POST') {
    return POST_ALLOWLIST.has(apiPath) || SIS_ACTION_POST_PATTERNS.some((pattern) => pattern.test(apiPath));
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
};

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
    'Accept, Authorization, Content-Type, App-Token, Session-Token',
  );
  headers.set('Access-Control-Expose-Headers', 'Content-Range, Accept-Range, ETag, X-GLPI-Snapshot-Hash, X-Consumer-Id');
  headers.set('Vary', 'Origin');
  return new Response(response.body, {
    status: response.status,
    statusText: response.statusText,
    headers,
  });
}
