/**
 * @author admin
 */
;(function($, $mo) {

App.ProjectsEdit = function() {
    App.ProjectsEdit.superclass.constructor.call(this);
}

App.ProjectsEdit.prototype = {
    members : [],
    members_cnt : Number(Ext.get('members_cnt').dom.value),

    initialize: function() {
        $mo.fire('created_page');

        this.set_events();
        this.set_elements();
    },

    set_events : function()
    {
		// Save Settings button click
        $('#btn_add_project').click($mo.scope(this, this.save));
		// Change Settings button click
        $('#btn_edit_project').click($mo.scope(this, this.save));
    },

    set_elements: function()
    {
        // @TODO: Initialization of the form elements in the dialog
        var ef = Ext.form;
        var m1 = 'project'  + '_';
        var m2 = 'template' + '_';

        // Project Name
        this.form_project_name        = new ef.TextField({ applyTo: m1+'project_name', selectOnFocus:true, validateOnBlur:false, validationEvent:false,
                                                           allowBlank:false, blankText: 'The Project Name is required.',
                                                           msgTarget: 'title'
                                                         });
        // Project Code
        this.form_project_cd          = new ef.TextField({ applyTo: m1+'project_cd', selectOnFocus:true, validateOnBlur:false, validationEvent:false,
                                                           allowBlank:false, blankText: 'Delivery Order ID is required.',
                                                           msgTarget: 'title'
                                                         });
        // End User Name
        this.form_end_user_name       = new ef.TextField({ applyTo: m1+'end_user_name', selectOnFocus:true, validateOnBlur:false, validationEvent:false,
                                                           allowBlank:false, blankText: 'Customer Name is required.',
                                                           msgTarget: 'title'
                                                         });
        // Start Date
        this.form_start_date          = new ef.DateField({ applyTo: m1+'start_date', selectOnFocus:true, validateOnBlur:false, validationEvent:false,
                                                           allowBlank:false, blankText: 'Start date is required.', invalidText: 'Invalid start date',
                                                           msgTarget: 'title', format: "Y-m-d"
                                                         });
        // End Date
        this.form_delivery_date       = new ef.DateField({ applyTo: m1+'delivery_date', selectOnFocus:true, validateOnBlur:false, validationEvent:false,
                                                           allowBlank:false, blankText: 'End date is required。', invalidText: 'Invalid end date',
                                                           msgTarget: 'title', format: "Y-m-d"
                                                         });
        // Templates
        this.form_template_id         = new ef.ComboBoxEx({ transform: m2+'id', selectOnFocus:true, validateOnBlur:false, validationEvent:false,
                                                            msgTarget: 'title', style: 'width: 212px;', editable:false, triggerAction: "all"
                                                          });
        // Participating members
        var elms = Ext.query( 'input.members_field' ) ;
        for( var i=0 ; i<elms.length ; i++ ){
            var e = elms[i] ;
            this.set_member_event(e.id);
        }

        // Check Events
        set_invalid_event(this.form_project_name);
        set_invalid_event(this.form_project_cd);
        set_invalid_event(this.form_end_user_name);
        set_invalid_event(this.form_start_date);
        set_invalid_event(this.form_delivery_date);
    },

    set_member_event: function(id){
        var ef = Ext.form;
        // Participating members
        var email = new ef.TextField({ applyTo: id, selectOnFocus:true, validateOnBlur:false, validationEvent:false,
                                       vtype: 'email', vtypeText: 'Participant email is invalid.',
                                       msgTarget: 'title'
                                     });
        this.members.push(email);
        set_invalid_event(email);

    },

    validate: function() {
        // @TODO: Input check
        var rtn = ( this.form_project_name.validate() &&
                    this.form_project_cd.validate() &&
                    this.form_end_user_name.validate() &&
                    this.form_start_date.validate() &&
                    this.form_delivery_date.validate()
                  );
        if (!rtn) return false;
        for(var i=0;i<this.members.length;i++){
            if (!this.members[i].validate()) return false;
        }

        return true;
    },

    // messaage
    messages: {
        created: "Create a project with this information. \n Are you sure?",
        updated: "Update the information in this project. \n Are you sure?"
    },

    save : function(o){
        if (!o || !o.target) return false;
        var confirm_message;
        switch (o.target.id){
            case 'btn_add_project':
                confirm_message = this.messages.created;
                break;
            case 'btn_edit_project':
                confirm_message = this.messages.updated;
                break;
        }

        // Check before and after the period
        var between_valid = fncBackToForth(this.form_start_date.getRawValue(), this.form_delivery_date.getRawValue());
        if (!between_valid) {
            alert('Time period is incorrect');
            return false;
        }

        // Input check
        if (!this.validate() || !confirm(confirm_message)) return false;

		form = document.edit_project_form;
		form.submit();
    },

    onEmailFieldAdd : function(area_id){
        this.members_cnt += 1;
        var cnt = this.members_cnt;
        var field = '<div id="email_pro_inp_'+ cnt +'">' +
                    '<input id="users_' + cnt + '" maxlength="256" name="users[]" size="256" style="width:212px;ime-mode:disabled;margin-bottom:2px;" class ="members_field" type="text" />' +
                    '&nbsp;' +
                    '<a href="#" onclick="$page.onEmailFieldRemove(\'email_pro_inp_' + cnt + '\'); return false;"><span >Delete</span>&nbsp;</a>' +
                    '</div>' ;
        // Adding additional text fields for address
        var obj = Ext.get(area_id);
        obj.insertHtml('beforeEnd', field);

        var id = 'users_'+ cnt;
        this.set_member_event(id);
    },

    onEmailFieldRemove : function(span_id){
        // Delete the text field to add the address
        var elm = Ext.get(span_id) ;
        elm.remove();
        this.members_cnt -= 1;

        // Participating members
        this.members = [];
        var elms = Ext.query( 'input.members_field' ) ;
        for( var i=0 ; i<elms.length ; i++ ){
            var e = elms[i] ;
            this.set_member_event(e.id);
        }
    },

    loaded: function()
    {
    }
}

Motto.extend(App.ProjectsEdit, Page);
window.$page = $page = new App.ProjectsEdit();

})(jQuery, Motto);
