/**
 * @author admin
 */

 ;(function($, $mo) {

    $mo.namespace('components.projects.task_report_dialog');

components.projects.task_report_dialog = function(project_cd)
{
    dialog = function(project_cd) {
        dialog.superclass.constructor.call(this);
        this.project_cd = project_cd;
    }
    dialog.prototype = {
        // dialog config
        width: 450,
        container: 'projects_task_report_dialog',
        form: this.container + '_form',
        comp_id: null,

        // url
        load_url: url_for('projects/' + project_cd + '/tasks/' + project_cd + '/reports/new'),
        data_url: url_for('projects/' + project_cd + '/tasks/' + project_cd + '/reports/{:id}.json'),

        // messaage
        messages: {
            created: "Create a report with this information. \nAre you sure?"
        },
        initialize: function() {
            this.form = this.container + '_form';
        },
        loadedDialog: function() {
            this.set_signals();
            this.set_elements();
            this.set_events();
        },
        set_signals: function() {
            $mo.connect('open_' + this.container, this.open, this);
            $mo.connect('close_' + this.container, this.close, this);
        },
        set_events: function() {
            $('#' + this.container + '_save').click($mo.scope(this, this.save));
            $('#' + this.container + '_close').click($mo.callback('close_' + this.container));

            // Complete check box event set
            this.form_progress_kbn.addListener('check', this.onProgressKbnClick, this, true) ;
            // Event setting percent complete
            this.form_progress_rate.addListener("blur", this.onProgressRateChange, this, true) ;

        },
        set_elements: function()
        {
            // @TODO: Initialization of the form elements in the dialog
            var ef = Ext.form;
            var m1 = 'dlg_tsk_report_task' + '_';

            this.form_report_id             = new ef.Hidden(m1+'id');

            // Report Date
            this.form_report_date           = new ef.DateField({ applyTo: m1+'report_date', selectOnFocus:true, validateOnBlur:false, validationEvent:false,
                                                                 allowBlank:false, blankText: 'The report date is required.',
                                                                 msgTarget: 'title', format:"Y-m-d", value:(new Date()).format('Y-m-d')
                                                               });
            // Progress Rate
            this.form_progress_rate         = new ef.ComboBoxEx({ transform: m1+'progress_rate', selectOnFocus:true, validateOnBlur:false, validationEvent:false,
                                                                  msgTarget: 'title', style: 'width:80px;', editable:false, triggerAction: "all"
                                                               });
            // Complete
            this.form_progress_kbn          = new ef.Checkbox({ applyTo: m1+'progress_kbn', selectOnFocus:true, validateOnBlur:false, validationEvent:false,
                                                                msgTarget: 'title'
                                                               });

            // Notes
            this.form_memo                  = new ef.TextArea({ applyTo: m1+'memo', selectOnFocus:true, validateOnBlur:false, validationEvent:false,
                                                                msgTarget: 'title'
                                                               });
            // Check Events
            this.form_report_date.on( 'invalid', invalid_alert, this );

        },
        onProgressKbnClick : function(){
            if(this.form_progress_kbn.getValue()){
                this.form_progress_rate.setValue('10');
            }
            else{
                if( this.form_progress_rate.getValue() == '10' ){
                    this.form_progress_rate.setValue('0');
                }
            }
        },
        onProgressRateChange : function(){
            if(this.form_progress_rate.getValue() == '10' ){
                this.form_progress_kbn.setValue(true);
            }
            else{
                this.form_progress_kbn.setValue(false);
            }
        },
        reset_form: function()
        {
            // @TODO: Reset Form Processing
            this.comp_id = null;
            this.form_report_id.reset();
            this.form_report_date.setRawValue((new Date()).format('Y-m-d'));
            this.form_progress_rate.reset();
            this.form_progress_kbn.reset();
            this.form_memo.reset();
        },
        validate: function() {
            // @TODO: Input check
            return ( this.form_report_date.validate()
                   ) ? true : false;
        },
        onBeforeShow: function()
        {
            this.form_report_id.setValue(this.comp_id);
        },
        onBeforeHide: function()
        {
            // @TODO: Before you close the dialog process
            this.reset_form();
        },

        /**
         * SAVE
         */
        save: function()
        {
            var url = this.data_url.replace('/{:id}', '');
            var method = 'post';
            var confirm_message = this.messages.created;

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
                location.reload(true);
            } else {
                alert(message);
            }
        },
        onSaveFailure: function(r) {
            var message = $mo.decode(r.responseText).message;
            alert(message);
        }
    };

    $mo.extend(dialog, Motto.ui.Dialog);
    var dialog = new dialog(project_cd);
}


})(jQuery, Motto);
