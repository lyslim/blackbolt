/**
 * @author admin
 */
;(function($, $mo) {

App.UsersNew = function() {
    App.UsersNew.superclass.constructor.call(this);
}

App.UsersNew.prototype = {
    initialize: function() {
        this.set_events();
        this.set_elements();
    },

    set_events : function()
    {
        $('#btn_save').click($mo.scope(this, this.save));
    },

    set_elements: function()
    {
        // @TODO: Initialization of the form elements in the dialog
        var ef = Ext.form;
        var m = 'user' + '_';

        // Login
        this.form_login_id             = new ef.TextField({ applyTo: m+'login_id', selectOnFocus:true, validateOnBlur:false, validationEvent:false,
                                                            allowBlank:false, blankText: 'Login id is required.',
                                                            msgTarget: 'title'
                                                           });
        // Password
        this.form_srcpassword          = new ef.TextField({ applyTo: m+'srcpassword', selectOnFocus:true, validateOnBlur:false, validationEvent:false,
                                                            allowBlank:false, blankText: 'Password is required',
                                                            msgTarget: 'title'
                                                           });
        // Name
        this.form_user_name            = new ef.TextField({ applyTo: m+'user_name', selectOnFocus:true, validateOnBlur:false, validationEvent:false,
                                                            allowBlank:false, blankText: 'Name is required.',
                                                            msgTarget: 'title'
                                                           });
        // Email
        this.form_email                = new ef.TextField({ applyTo: m+'email', selectOnFocus:true, validateOnBlur:false, validationEvent:false,
                                                            allowBlank:false, blankText: 'Email is required.', vtype: 'email', vtypeText: 'Invalid Email',
                                                            msgTarget: 'title'
                                                           });
        // Check Events
        this.form_login_id.on    ( 'invalid', invalid_alert, this );
        this.form_srcpassword.on ( 'invalid', invalid_alert, this );
        this.form_user_name.on   ( 'invalid', invalid_alert, this );
        this.form_email.on       ( 'invalid', invalid_alert, this );
    },

    validate: function() {
        // @TODO: Input check
        return ( this.form_login_id.validate() &&
                 this.form_srcpassword.validate() &&
                 this.form_user_name.validate() &&
                 this.form_email.validate()
        ) ? true : false;
    },

    // messaage
    messages: {
        created: "Create an account with this information. \n Are you sure?"
    },

    save : function(){
        var confirm_message = this.messages.created;
        // Input check
        if (!this.validate() || !confirm(confirm_message)) return false;

		form = document.user_form;
		form.submit();
    },

    loaded: function()
    {
    }
}

Motto.extend(App.UsersNew, Page);
window.$page = $page = new App.UsersNew();

})(jQuery, Motto);
