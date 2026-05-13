const GLPI_ORIGIN = 'http://cau.ppiratini.intra.rs.gov.br';

export default {
  async fetch(request, env) {
    const incoming = new URL(request.url);
    const target = new URL(incoming.pathname + incoming.search, GLPI_ORIGIN);
    return env.GLPI.fetch(new Request(target, request));
  },
};
