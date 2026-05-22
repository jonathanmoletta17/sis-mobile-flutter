const GLPI_ORIGIN = 'http://10.72.30.39';
const GLPI_API_PREFIX = '/glpi/apirest.php';

const READ_ONLY_ITEM_PATTERN =
  /^\/(?:initSession|search\/Ticket|Ticket(?:\/\d+(?:\/(?:TicketFollowup|ITILSolution|Ticket_User|Document))?)?|Document(?:\/\d+)?|Document_Item|ITILFollowup\/\d+\/Document_Item|ITILSolution\/\d+\/Document_Item|User(?:\/\d+)?|Profile(?:\/\d+)?|Entity|Location|RequestType|ITILCategory|PluginFormcreator(?:Form|Form_Profile|Category|Section|Question|TargetTicket|QuestionDependency|Condition)(?:\/\d+)?|listSearchOptions\/Ticket|getFullSession|getActiveProfile|getMyProfiles|getMyEntities)(?:$|[/?])/;

const POST_ALLOWLIST = new Set(['/initSession']);
const GET_ALLOWLIST = new Set(['/killSession']);
const TICKET_ACTION_POST_PATTERNS = [
  /^\/TicketFollowup(?:$|[/?])/,
  /^\/ITILSolution(?:$|[/?])/,
  /^\/Ticket_User(?:$|[/?])/,
  /^\/(?:Ticket|ITILFollowup|ITILSolution)\/\d+\/Document(?:$|[/?])/,
];
const TICKET_ACTION_PUT_PATTERN = /^\/(?:Ticket|ITILSolution)\/\d+(?:$|[/?])/;

const worker = {
  async fetch(request, env) {
    if (request.method === 'OPTIONS') {
      return withCors(new Response(null, { status: 204 }));
    }

    const incoming = new URL(request.url);
    if (request.method === 'GET' && incoming.pathname === '/healthz') {
      return withCors(new Response('ok', {
        status: 200,
        headers: {'Content-Type': 'text/plain; charset=utf-8'},
      }));
    }

    const glpiPath = normalizeGlpiPath(incoming.pathname);
    const apiPath = glpiPath.slice(GLPI_API_PREFIX.length) || '/';

    if (!isAllowedRequest(request.method, apiPath, env)) {
      return jsonError(403, 'Endpoint blocked by DTIC Worker allowlist.');
    }

    const appToken = env.GLPI_APP_TOKEN;
    if (!appToken) {
      return jsonError(500, 'GLPI_APP_TOKEN secret is not configured.');
    }

    const target = new URL(glpiPath + incoming.search, GLPI_ORIGIN);
    const headers = new Headers(request.headers);
    headers.set('App-Token', appToken);
    headers.delete('Host');

    const upstreamRequest = new Request(target, {
      method: request.method,
      headers,
      body: hasRequestBody(request.method) ? request.body : undefined,
      redirect: 'manual',
    });

    try {
      return withCors(await env.GLPI.fetch(upstreamRequest));
    } catch {
      return jsonError(502, 'DTIC upstream unavailable through Workers VPC.');
    }
  },
};

export default worker;

function normalizeGlpiPath(pathname) {
  if (pathname.startsWith(GLPI_API_PREFIX)) {
    return pathname;
  }
  if (pathname.startsWith('/apirest.php')) {
    return `/glpi${pathname}`;
  }
  return `${GLPI_API_PREFIX}${pathname.startsWith('/') ? pathname : `/${pathname}`}`;
}

function isAllowedRequest(method, apiPath, env) {
  if (method === 'GET') {
    return GET_ALLOWLIST.has(apiPath) || READ_ONLY_ITEM_PATTERN.test(apiPath);
  }
  if (method === 'POST') {
    if (POST_ALLOWLIST.has(apiPath)) return true;
    if (
      env.ALLOW_TICKET_ACTIONS === 'true' &&
      TICKET_ACTION_POST_PATTERNS.some((pattern) => pattern.test(apiPath))
    ) {
      return true;
    }
    return (
      env.ALLOW_FORMCREATOR_SUBMISSION === 'true' &&
      apiPath === '/PluginFormcreatorFormAnswer'
    );
  }
  if (method === 'PUT') {
    return (
      env.ALLOW_TICKET_ACTIONS === 'true' &&
      TICKET_ACTION_PUT_PATTERN.test(apiPath)
    );
  }
  return false;
}

export const __test = {
  fetch: (...args) => worker.fetch(...args),
  isAllowedRequest,
};

function hasRequestBody(method) {
  return method !== 'GET' && method !== 'HEAD';
}

function jsonError(status, message) {
  return withCors(new Response(JSON.stringify({ error: message }), {
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
  headers.set('Access-Control-Expose-Headers', 'Content-Range, Accept-Range');
  headers.set('Vary', 'Origin');
  return new Response(response.body, {
    status: response.status,
    statusText: response.statusText,
    headers,
  });
}
