/**
 * @author admin
 */
;(function($, $mo) {

App.AccountEdit = function() {
    App.AccountEdit.superclass.constructor.call(this);
}

App.AccountEdit.prototype = {

    initialize: function() {
        $mo.fire('created_page');

        this.set_events();
        this.set_elements();
    },

    set_events : function()
    {
		// 更改设置按钮
        $('#btn_save').click($mo.scope(this, this.save));
    },

    set_elements: function()
    {
        // @TODO: 初始化对话框的表单元素
        var ef = Ext.form;
        var m  = 'user'  + '_';

        // 用户名
        this.form_user_name         = new ef.TextField({ applyTo: m+'user_name', selectOnFocus:true, validateOnBlur:false, validationEvent:false,
                                                         allowBlank:false, blankText: 'User name is required.',
                                                         msgTarget: 'title'
                                                       });
        // 电邮
        this.form_email             = new ef.TextField({ applyTo: m+'email', selectOnFocus:true, validateOnBlur:false, validationEvent:false,
                                                         allowBlank:false, blankText: 'Email is required.', vtype: 'email', vtypeText: 'Invalid email',
                                                         msgTarget: 'title'
                                                       });
        // 密码
        this.form_srcpassword       = new ef.TextField({ applyTo: m+'srcpassword', selectOnFocus:true, validateOnBlur:false, validationEvent:false,
                                                         allowBlank:false, blankText: 'Password is required',
                                                         msgTarget: 'title'
                                                       });
        // 姓名
        this.form_name              = new ef.TextField({ applyTo: m+'name', selectOnFocus:true, validateOnBlur:false, validationEvent:false,
                                                         msgTarget: 'title'
                                                       });
        // 生日
        this.form_birthday          = new ef.DateField({ applyTo: m+'birthday', selectOnFocus:true, validateOnBlur:false, validationEvent:false,
                                                         invalidText: 'Invalid birthday',
                                                         msgTarget: 'title', format: "Y-m-d"
                                                       });
        // 公司名
        this.form_company_name      = new ef.TextField({ applyTo: m+'company_name', selectOnFocus:true, validateOnBlur:false, validationEvent:false,
                                                         msgTarget: 'title'
                                                       });
        // 部门名
        this.form_section_name      = new ef.TextField({ applyTo: m+'section_name', selectOnFocus:true, validateOnBlur:false, validationEvent:false,
                                                         msgTarget: 'title'
                                                       });
        // 邮编
        this.form_zip               = new ef.TextField({ applyTo: m+'zip', selectOnFocus:true, validateOnBlur:false, validationEvent:false,
                                                         msgTarget: 'title', maxLength: 8
                                                       });
        // 都道府県
        this.form_prefecture        = new ef.TextField({ applyTo: m+'prefecture', selectOnFocus:true, validateOnBlur:false, validationEvent:false,
                                                         msgTarget: 'title', maxLength: 10
                                                       });
        // 地址１
        this.form_address1          = new ef.TextField({ applyTo: m+'address1', selectOnFocus:true, validateOnBlur:false, validationEvent:false,
                                                         msgTarget: 'title'
                                                       });
        // 地址２
        this.form_address2          = new ef.TextField({ applyTo: m+'address2', selectOnFocus:true, validateOnBlur:false, validationEvent:false,
                                                         msgTarget: 'title'
                                                       });
        // 电话
        this.form_tel               = new ef.TextField({ applyTo: m+'tel', selectOnFocus:true, validateOnBlur:false, validationEvent:false,
                                                         msgTarget: 'title', maxLength: 14
                                                       });
        // 传真
        this.form_fax               = new ef.TextField({ applyTo: m+'fax', selectOnFocus:true, validateOnBlur:false, validationEvent:false,
                                                         msgTarget: 'title', maxLength: 14
                                                       });
        // Skype ID
        this.form_skype_id          = new ef.TextField({ applyTo: m+'skype_id', selectOnFocus:true, validateOnBlur:false, validationEvent:false,
                                                         msgTarget: 'title'
                                                       });

        //check events
        set_invalid_event(this.form_user_name);
        set_invalid_event(this.form_email);
        set_invalid_event(this.form_srcpassword);
        set_invalid_event(this.form_birthday);
    },

    validate: function() {
        // @TODO: input check
        var rtn = ( this.form_user_name.validate() &&
                    this.form_email.validate() &&
                    this.form_srcpassword.validate() &&
                    this.form_birthday.validate()
                  );
        return rtn ? true : false;
    },

    // messaage
    messages: {
        updated: "Update your account information. \ n Do you want?"
    },

    save : function(o){
        var confirm_message = this.messages.updated;

        // Input check
        if (!this.validate() || !confirm(confirm_message)) return false;

		form = document.account_form;
		form.submit();
    },

    loaded: function()
    {
    }
}

Motto.extend(App.AccountEdit, Page);
window.$page = $page = new App.AccountEdit();

})(jQuery, Motto);
