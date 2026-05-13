const GLPI_ORIGIN = 'http://cau.ppiratini.intra.rs.gov.br';
const GLPI_API_PREFIX = '/glpi/apirest.php';

const READ_ONLY_ITEM_PATTERN =
  /^\/(?:search\/Ticket|Ticket(?:\/\d+(?:\/(?:TicketFollowup|ITILSolution|Ticket_User|Document))?)?|Document(?:\/\d+)?|Document_Item|ITILFollowup\/\d+\/Document_Item|ITILSolution\/\d+\/Document_Item|User(?:\/\d+)?|Entity|Location|RequestType|ITILCategory|PluginFormcreator(?:Form|Category|Section|Question|TargetTicket|QuestionDependency|Condition)(?:\/\d+)?|listSearchOptions\/Ticket|getFullSession|getActiveProfile|getMyProfiles|getMyEntities)(?:$|[/?])/;

const POST_ALLOWLIST = new Set(['/initSession']);
const GET_ALLOWLIST = new Set(['/killSession']);
const TICKET_ACTION_POST_PATTERNS = [
  /^\/TicketFollowup(?:$|[/?])/,
  /^\/ITILSolution(?:$|[/?])/,
  /^\/Ticket_User(?:$|[/?])/,
  /^\/Document(?:$|[/?])/,
  /^\/Document_Item(?:$|[/?])/,
  /^\/(?:Ticket|ITILFollowup|ITILSolution)\/\d+\/Document(?:$|[/?])/,
];
const TICKET_ACTION_PUT_PATTERN = /^\/(?:Ticket|ITILSolution)\/\d+(?:$|[/?])/;

export default {
  async fetch(request, env) {
    if (request.method === 'OPTIONS') {
      return new Response(null, { status: 204 });
    }

    const appToken = env.GLPI_APP_TOKEN;
    if (!appToken) {
      return jsonError(500, 'GLPI_APP_TOKEN secret is not configured.');
    }

    const incoming = new URL(request.url);
    const glpiPath = normalizeGlpiPath(incoming.pathname);
    const apiPath = glpiPath.slice(GLPI_API_PREFIX.length) || '/';

    if (!isAllowedRequest(request.method, apiPath, env)) {
      return jsonError(403, 'Endpoint blocked by DTIC Worker allowlist.');
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

    return env.GLPI.fetch(upstreamRequest);
  },
};

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
  isAllowedRequest,
};

function hasRequestBody(method) {
  return method !== 'GET' && method !== 'HEAD';
}

function jsonError(status, message) {
  return new Response(JSON.stringify({ error: message }), {
    status,
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
    },
  });
}
