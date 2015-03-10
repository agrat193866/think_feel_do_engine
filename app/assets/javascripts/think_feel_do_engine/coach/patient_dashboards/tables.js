$(function() {
    return $('.generic-data-table').dataTable({
        sPaginationType: 'bootstrap',
        oLanguage: {
            sSearch: 'Filter: '
        }
    });
});

$(function() {
    return $('#learning_data').dataTable({
        sPaginationType: 'bootstrap',
        order: [[0, "desc"]],
        oLanguage: {
            sSearch: 'Filter: '
        },
        aoColumnDefs: [
            {
                aTargets: [0],
                bVisible: false
            },
            {
                aTargets: [4],
                iDataSort: [0]
            },
            {
                aTargets: [1],
                bVisible: false
            },
            {
                aTargets: [5],
                iDataSort: [1]
            },
            {
                aTargets: [2],
                bVisible: false
            },
            {
                aTargets: [6],
                iDataSort: [2]
            }
        ],
        oLanguage: {
            sSearch: 'Filter: '
        }
    });
});

$(function() {
    return $('#access_data').dataTable({
        sPaginationType: 'bootstrap',
        order: [[0, "desc"]],
        oLanguage: {
            sSearch: 'Filter: '
        },
        aoColumnDefs: [
            {
                aTargets: [0],
                bVisible: false
            },
            {
                aTargets: [2],
                iDataSort: [0]
            }
        ],
        oLanguage: {
            sSearch: 'Filter: '
        }
    });
});

$(function() {
    return $('#task_statuses').dataTable({
        sPaginationType: 'bootstrap',
        order: [[0, "asc"]],
        oLanguage: {
            sSearch: 'Filter: '
        },
        aoColumnDefs: [
            {
                aTargets: [0],
                bVisible: false
            },
            {
                aTargets: [3],
                iDataSort: [0]
            }
        ],
        oLanguage: {
            sSearch: 'Filter: '
        }
    });
});

$(function() {
    return $('#moods-table').dataTable({
        sPaginationType: 'bootstrap',
        order: [[2, "desc"]],
        oLanguage: {
            sSearch: 'Filter: '
        },
        aoColumnDefs: [
            {
                aTargets: [0],
                bVisible: false
            },
            {
                aTargets: [2],
                iDataSort: [0]
            }
        ]
    });
});

$(function() {
    return $('#emotions-table').dataTable({
        sPaginationType: 'bootstrap',
        order: [[2, "desc"]],
        oLanguage: {
            sSearch: 'Filter: '
        },
        aoColumnDefs: [
            {
                aTargets: [0],
                bVisible: false
            },
            {
                aTargets: [2],
                iDataSort: [0]
            }
        ]
    });
});

$(function() {
    return $('#activities_future').dataTable({
        sPaginationType: 'bootstrap',
        order: [[6, "desc"]],
        oLanguage: {
            sSearch: 'Filter: '
        },
        aoColumnDefs: [
            {
                aTargets: [0],
                bVisible: false
            },
            {
                aTargets: [5],
                iDataSort: [0]
            },
            {
                aTargets: [1],
                bVisible: false
            },
            {
                aTargets: [6],
                iDataSort: [1]
            }
        ]
    });
});

$(function() {
    return $('#activities_past').dataTable({
        sPaginationType: 'bootstrap',
        order: [[10, "desc"]],
        oLanguage: {
            sSearch: 'Filter: '
        },
        aoColumnDefs: [
            {
                aTargets: [0],
                bVisible: false
            },
            {
                aTargets: [8],
                iDataSort: [0]
            },
            {
                aTargets: [1],
                bVisible: false
            },
            {
                aTargets: [9],
                iDataSort: [1]
            }
        ]
    });
});

$(function() {
    return $('#logins').dataTable({
        sPaginationType: 'bootstrap',
        order: [[1, "desc"]],
        oLanguage: {
            sSearch: 'Filter: '
        },
        aoColumnDefs: [
            {
                aTargets: [0],
                bVisible: false
            },
            {
                aTargets: [1],
                iDataSort: [0]
            }
        ]
    });
});
