/**
 * @author admin
 */

 ;(function($, $mo) {

    $mo.namespace('components.projects.milestone_edit_dialog');

components.projects.milestone_edit_dialog = function(project_cd)
{
    dialog = function(project_cd) {
        dialog.superclass.constructor.call(this);
        this.project_cd = project_cd;
    }
    dialog.prototype = {
        // dialog config
        width: 450,
        container: 'projects_milestone_edit_dialog',
        form: this.container + '_form',
        comp_id: null,

        // url
        load_url: url_for('projects/' + project_cd + '/milestones/new'),
        data_url: url_for('projects/' + project_cd + '/milestones/{:id}.json'),

        // messaage
        messages: {
            created: "Create a milestone with this information. \n Are you sure?",
            updated: "Update the information on this milestone. \n Are you sure?",
            deleted: "Delete this milestone. \n Are you sure?"
        },
        initialize: function() {
            this.form = this.container + '_form';
        },
        loadedDialog: function() {
            this.set_signals();
            this.set_events();
            this.set_elements();
        },
        set_signals: function() {
            $mo.connect('open_' + this.container, this.open, this);
            $mo.connect('close_' + this.container, this.close, this);
        },
        set_events: function() {
            $('#' + this.container + '_save').click($mo.scope(this, this.save));
            $('#' + this.container + '_destroy').click($mo.scope(this, this.destroy));
            $('#' + this.container + '_close').click($mo.callback('close_' + this.container));
        },
        set_elements: function()
        {
            // @TODO: Initialization of the form elements in the dialog
            var ef = Ext.form;
            var m1 = 'dlg_mil_edit_miles' + '_';
            var m2 = 'dlg_mil_edit_comp' + '_';

            this.form_milestone_id          = new ef.Hidden(m1+'id');
            this.form_comp_id               = new ef.Hidden(m2+'id');
            this.form_task_kbn              = new ef.Hidden(m2+'task_kbn');

            // Milestone
            this.form_item_name             = new ef.TextField({ applyTo: m2+'item_name', selectOnFocus:true, validateOnBlur:false, validationEvent:false,
                                                                 allowBlank:false, blankText: 'Milestone is required.',
                                                                 msgTarget: 'title'
                                                               });
            // Date
            this.form_mils_date             = new ef.DateField({ applyTo: m1+'mils_date', selectOnFocus:true, validateOnBlur:false, validationEvent:false,
                                                                 msgTarget: 'title', format:"Y-m-d"
                                                               });
            // Classification
            this.form_class_word1           = new ef.TextField({ applyTo: m2+'class_word1', selectOnFocus:true, validateOnBlur:false, validationEvent:false,
                                                                 msgTarget: 'title'
                                                               });
            // Classification
            this.form_class_word2           = new ef.TextField({ applyTo: m2+'class_word2', selectOnFocus:true, validateOnBlur:false, validationEvent:false,
                                                                 msgTarget: 'title'
                                                               });
            // Classification
            this.form_class_word3           = new ef.TextField({ applyTo: m2+'class_word3', selectOnFocus:true, validateOnBlur:false, validationEvent:false,
                                                                 msgTarget: 'title'
                                                               });

            //Check Events
            this.form_item_name.on( 'invalid', invalid_alert, this );

        },
        reset_form: function()
        {
            // @TODO: Reset Form Processing
            this.comp_id = null;
            $('#' + this.container + '_destroy').css("display","none");
            this.form_milestone_id.setRawValue('');
            this.form_comp_id.setRawValue('');
            this.form_task_kbn.setRawValue('');
            this.form_item_name.setRawValue('');
            this.form_mils_date.setRawValue('');
            this.form_class_word1.setRawValue('');
            this.form_class_word2.setRawValue('');
            this.form_class_word3.setRawValue('');
        },
        set_form_data: function(r)
        {
            var miles = r.miles;
            if (miles.id) {
                $('#' + this.container + '_destroy').css("display","inline");
            } else {
                $('#' + this.container + '_destroy').css("display","none");
            }
            var projectcomp = r.projectcomp;

            this.form_milestone_id.setRawValue(miles.id || '');
            this.form_comp_id.setRawValue(projectcomp.id || '');
            this.form_task_kbn.setRawValue(projectcomp.task_kbn || '');
            this.form_item_name.setRawValue(projectcomp.item_name || '');
            this.form_mils_date.setRawValue(miles.mils_date || '');
            this.form_class_word1.setRawValue(projectcomp.class_word1 || '');
            this.form_class_word2.setRawValue(projectcomp.class_word2 || '');
            this.form_class_word3.setRawValue(projectcomp.class_word3 || '');
        },
        validate: function() {
            // @TODO: Input check
            return this.form_item_name.validate() ? true : false;
        },
        onBeforeShow: function()
        {
            // @TODO: Preprocessing dialog display
            this.load_data();
        },
        onBeforeHide: function()
        {
            // @TODO: Before you close the dialog process
            this.reset_form();
        },

        /**
         * Load Data
         */
        load_data: function() {
            if (this.comp_id) {
                var url = this.data_url.replace('{:id}', this.comp_id);
                var opt = {
                    url: url,
                    success: this.onLoadSuccess,
                    failure: this.onLoadFailure,
                    method: 'get',
                    scope: this
                }
                Ext.Ajax.request(opt);
            }

        },
        onLoadSuccess: function(r) {
            var r = $mo.decode(r.responseText);
            var success = r.success ;
            var message = r.message ;
            var resultobj = r.result ;
            if (success){
                this.set_form_data(resultobj);
            } else {
                this.close();
                alert(message);
            }
        },
        onLoadFailure: function(r) {
            var message = $mo.decode(r.responseText).message;
            alert(message);
        },

        /**
         * SAVE
         */
        save: function()
        {
            if (this.comp_id) {
                var url = this.data_url.replace('{:id}', this.comp_id);
                var method = 'put';
                var confirm_message = this.messages.updated;
            } else {
                var url = this.data_url.replace('/{:id}', '');
                var method = 'post';
                var confirm_message = this.messages.created;
            }

            if (this.validate() && confirm(confirm_message)) {
                var opt = {
                    url: url,
                    form: this.form,
                    success: this.onSaveSuccess,
                    failure: this.onSaveFailure,
                    scope: this,
                    method: method
                }
                Ext.Ajax.request(opt);
            }
        },
        onSaveSuccess: function(r) {            
            var r = $mo.decode(r.responseText);
            var success = r.success ;
            var message = r.message ;
            var resultobj = r.result ;
            if (success){
                this.close();
                $mo.fire('saved_' + this.container);
            } else {
                alert(message);
            }
        },
        onSaveFailure: function(r) {
            var message = $mo.decode(r.responseText).message;
            alert(message);
        },

        /**
         * Destroy
         */
        destroy: function() {
            // @TODO: Data removal process
            if (confirm(this.messages.deleted)) {
                var url = this.data_url.replace('{:id}', this.comp_id);
                var opt = {
                    url: url,
                    success: this.onDestroySuccess,
                    failure: this.onDestroyFailure,
                    scope: this,
                    method: 'delete'
                }
                Ext.Ajax.request(opt);
            }
        },
        onDestroySuccess: function(r) {            
            var r = $mo.decode(r.responseText);
            var success = r.success ;
            var message = r.message ;
            var resultobj = r.result ;
            if (success){
                this.close();
                $mo.fire('deleted_' + this.container);
            } else {
                alert(message);
            }
        },
        onDestroyFailure: function(r) {
            var message = $mo.decode(r.responseText).message;
            alert(message);
        }
    };

    $mo.extend(dialog, Motto.ui.Dialog);
    var dialog = new dialog(project_cd);
}


})(jQuery, Motto);
