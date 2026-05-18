const GLPI_ORIGIN = 'http://cau.ppiratini.intra.rs.gov.br';
const GLPI_API_PREFIX = '/sis/apirest.php';

const READ_ONLY_ITEM_PATTERN =
  /^\/(?:search\/Ticket|Ticket(?:\/\d+(?:\/(?:TicketFollowup|ITILSolution|Ticket_User|Document_Item|Document))?)?|Document(?:\/\d+)?|Document_Item|ITILFollowup\/\d+\/Document_Item|ITILSolution\/\d+\/Document_Item|User(?:\/\d+)?|Entity|Location|RequestType|ITILCategory|listSearchOptions\/Ticket|getFullSession|getActiveProfile|getMyProfiles|getMyEntities)(?:$|[/?])/;

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

export default {
  async fetch(request, env) {
    if (request.method === 'OPTIONS') {
      return new Response(null, { status: 204 });
    }

    const incoming = new URL(request.url);
    if (incoming.pathname === '/healthz') {
      return new Response('ok', {
        status: 200,
        headers: {'Content-Type': 'text/plain; charset=utf-8'},
      });
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

    const upstreamRequest = new Request(target, {
      method: request.method,
      headers,
      body: hasRequestBody(request.method) ? request.body : undefined,
      redirect: 'manual',
    });

    try {
      return await env.GLPI.fetch(upstreamRequest);
    } catch {
      return jsonError(502, 'SIS upstream unavailable through Workers VPC.');
    }
  },
};

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
  isAllowedRequest,
  normalizeGlpiPath,
};

function hasRequestBody(method) {
  return method !== 'GET' && method !== 'HEAD';
}

function jsonError(status, message) {
  return new Response(JSON.stringify({error: message}), {
    status,
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
    },
  });
}
