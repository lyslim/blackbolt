/**
 * @author admin
 */
;(function($, $mo) {

App.WorkforceResource = function() {
    App.WorkforceResource.superclass.constructor.call(this);
}

App.WorkforceResource.prototype = {

    initialize: function() {

        // grid
//		var p_cd = Ext.get('current_project_project_cd').dom.value;
        $('#resource_grid').workforce_resource_grid();

/*
        components.projects.task_edit_dialog(p_cd);
        components.projects.milestone_edit_dialog(p_cd);
        components.projects.event_edit_dialog(p_cd);
        this.member_select_dialog = components.projects.member_select_dialog(p_cd);
*/
        $mo.fire('created_page');
    },

    loaded: function()
    {
/*
		var p_cd = Ext.get('current_project_project_cd').dom.value;
        var args = {project_cd: p_cd};
        $('a#projects_gantt_btn_add_task').click(function() {
            $mo.fire('open_projects_task_edit_dialog', args);
        });
        $('a#projects_gantt_btn_add_milestone').click(function() {
            $mo.fire('open_projects_milestone_edit_dialog', args);
        });
        $('a#projects_gantt_btn_add_event').click(function() {
            $mo.fire('open_projects_event_edit_dialog', args);
        });
*/
    }
}

Motto.extend(App.WorkforceResource, Page);
window.$page = $page = new App.WorkforceResource();

})(jQuery, Motto);
