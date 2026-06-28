/// Configuração de grupos da instância SIS — aliases semânticos.
/// Esses IDs são específicos da instância SIS e NÃO devem ser hardcoded em testes.
/// Em vez disso, use esses aliases para manter a intenção semântica clara.
///
/// Quando a instância SIS mudar ou a instância DTIC for integrada, atualize
/// apenas esses arquivos (sis_instance_groups.dart e dtic_instance_groups.dart).

/// Grupo CC-Conservação na SIS.
const int sisConservationGroupId = 21;

/// Grupo CC-Manutenção na SIS.
const int sisMaintenanceGroupId = 22;

/// Grupo GG-Conservação na SIS.
const int sisGgConservationGroupId = 49;

/// Todos os IDs de grupo técnico na SIS.
const sisAllTechnicalGroupIds = {
  sisConservationGroupId,
  sisMaintenanceGroupId,
};

/// Todos os IDs de grupo na SIS.
const sisAllGroupIds = {
  sisConservationGroupId,
  sisMaintenanceGroupId,
  sisGgConservationGroupId,
};
