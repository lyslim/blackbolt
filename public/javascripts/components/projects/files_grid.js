/**
 * @author admin
 */

;(function($, $mo) {

$mo.namespace('components.projects.files_grid');

components.projects.files_grid = function(p_cd, p_name)
{
    var id = $(this).attr('id');
    if (id == '') { return this; }

    var panel = function(id, p_cd, p_name)
    {
        this.id     = id;
        this.p_cd   = p_cd;
        this.p_name = p_name;

        this.fncCreateFolderTree() ;
        this.fncCreateFileList() ;
        this.fncCreateLeftLayout() ;
        this.fncCreateCenterLayout() ;
        this.set_signals();
    }

    panel.prototype = {
        container      : 'files_grid',
        store_url_fo   : url_for('projects/' + p_cd + '/folders.json'),
        store_url_fi   : url_for('projects/' + p_cd + '/files.json'),
        item_url_fi    : url_for('projects/' + p_cd + '/files/{:id}.json'),

        messages: {
            deleted: app_localized_message("confirm", "delete_confirm")
        },

        tree_folder      : null,
        tree_root        : null,
    
        ds_list          : null,
        grid_list        : null,
        ctxMenu          : null,
        ctxMenu_difolt   : null,
        ctxMenu_file     : null,
        password         : null,
        check_pass_win   : null,
        check_pass_flg   : null,
        locked_flg       : true,
    
        left_panel       : null,
        center_panel     : null,

        current_node     :"/",

        set_signals: function() {
            $mo.connect('load', this.load_list, this);
            // folder
            $mo.connect('saved_projects_folder_edit_dialog', this.load_list, this);
            $mo.connect('deleted_projects_folder_edit_dialog', this.load_list, this);
            // file
            $mo.connect('saved_projects_file_edit_dialog', this.load_list, this);
            $mo.connect('deleted_projects_file_edit_dialog', this.load_list, this);
        },

        load_list: function() {
            this.load_data();

            var folder_tree = this.tree_folder;
            if (this.current_node) {
                var folder = folder_tree.getNodeById(this.current_node);
                folder.select();
            } else {
                this.tree_root.select() ;
            }

            var selmdl = this.tree_folder.getSelectionModel() ;
            var selnode = selmdl.getSelectedNode() ;
            selnode.loaded = false ;
            selnode.expand() ;

        },

        load_data: function(){
            var o = {
                url: this.store_url_fi,
                method: 'get',
                params: {
                    node:this.current_node
                },
                success: this.loaded_list,
                scope: this
            }
            Ext.Ajax.request(o);
        },

        loaded_list: function(r) {
            var r = Ext.decode(r.responseText);
            this.ds_list.loadData({items : r});
        },

        /*==================================================
         * Function Name：fncCreateFolderTree
         * Overview		：Generate Folder
         * Argument		：No
         * Return value	：No
         ==================================================*/
        fncCreateFolderTree : function(){
            //-----------------------------
            // Tree generation
            //-----------------------------
            this.tree_loader = new Ext.tree.TreeLoader({
                dataUrl       : this.store_url_fo,
                requestMethod : 'get'
            });
            this.tree_folder = new Ext.tree.TreePanel({
                autoScroll : true,
                animate : false,
                monitorResize : true ,
                region: 'center',
                margins: '0 0 0 0',
                border : false,
                loader: this.tree_loader
            });
            // set the root node
            this.tree_root = new Ext.tree.AsyncTreeNode({
                text: this.p_name,
                draggable:false,
                id: "/"
            });
            this.tree_folder.setRootNode(this.tree_root);
            this.tree_root.expand();
            this.tree_root.select() ;

            this.tree_folder.addListener( "click", this.onNodeClick, this, null ) ;

            // Right-click event grids
            this.tree_folder.on( "contextmenu", this.onRowContextMenu, this ) ;

            //-----------------------------
            // Context menu generation
            //-----------------------------
            this.ctxMenu = new Ext.menu.Menu({id: this.tree_folder.id + "-hctx"});
            this.ctxMenu.add(
                {id:"row_folder_edit", text: "Name change", cls: "grid-ctx-menu-edit"},
                {id:"row_folder_delete", text: "Delete", cls: "grid-ctx-menu-delete"}
            );
            this.ctxMenu.on("itemclick", this.onCtxMenuClick, this);

            //-----------------------------
            // 
            //-----------------------------
            this.ctxMenu_difolt = new Ext.menu.Menu({id: this.tree_folder.id + "-hctx2"});
            this.ctxMenu_difolt.add(
                {id:"rownew", text: app_localized_message("label", "newfolder"), cls: "grid-ctx-menu-new"}
            );
            this.ctxMenu_difolt.on("itemclick", this.onCtxMenuClick, this);

            this.tree_loader.addListener( 'beforeload', this.onTreeBeforeLoad, this, null ) ;
        },

        /*==================================================
         * Function Name：onNodeClick
         * Overview		：
         * Argument		： node            Ext.tree.TreeNode        
         *             	  e               Ext.EventObject             
         * Return Value	：No
         ==================================================*/
        onNodeClick : function( node,  e){
            this.current_node = node.id ;
            this.load_data() ;
        },

        /*==================================================
         * Function Name：onRowContextMenu
         * Overview		：
         * Argument		：grid              Ext.grid.Grid                 
         *       		：rowIndex          Number                         
         *       		：e                 Ext.EventObject                
         * Return Value：No
         ==================================================*/
        onRowContextMenu : function(node, e ){
            e.stopEvent();
            node.select();
            var pos = e.getXY() ;
            if (node.id == '/') {
                return false;
            } else {
                this.ctxMenu.showAt(pos) ;
            }
        },

        /*==================================================
         * Function Name：onCtxMenuClick
         * Overview		：
         * Argument		：baseItem          Ext.menu.BaseItem              
         *       		：e                 Ext.EventObject               
         * Return Value：No
         ==================================================*/
        onCtxMenuClick : function(baseItem, e){
            switch( baseItem.id ){
                case 'row_folder_edit'     : this.fncInsideFolderEdit(); break ;// Edit the folder name
                case 'row_folder_delete'   : this.fncGetInsideIdToDestroy(); break ;// Delete
            }
        },

        /*==================================================
         * Function Name：onTreeBeforeLoad
         * Overview		：
         * Argument		： treeloader     Ext.tree.TreeLoader     
         *             	: node            Ext.tree.TreeNode        
         *             	: e                Ext.EventObject             
         * Return Value：No
         ==================================================*/
        onTreeBeforeLoad : function( treeloader, node, callback  ){
            treeloader.baseParams.file_folder_id = node.attributes.id;
        },

        //submenu for a list
        fncInsideFolderEdit : function(){
            var selmdl = this.tree_folder.getSelectionModel() ;
            var selnode = selmdl.getSelectedNode() ;
            var id = selnode.id ;
            id = id.slice(0, -1);
            var fname = selnode.text ;
            this.fncDoEditFolder(id, fname);
        },

        fncGetInsideIdToDestroy : function(){
            var selmdl = this.tree_folder.getSelectionModel() ;
            var selnode = selmdl.getSelectedNode() ;
            var id = selnode.id;
            id = id.slice(0, -1);

            this.fncDestroyFile(id);
        },

        /*==================================================
         * Function Name：fncCreateFileList
         * Overview		：Generate a list of files
         * Argument		：No
         * Return Value	：No
         ==================================================*/
        fncCreateFileList : function(){
            //-----------------------------
            // Grid data store generation
            //-----------------------------
            this.ds_list = new Ext.data.JsonStore({
                root: "items",
                fields:[
                        {name: 'id',                    mapping:'id'},
                        {name: 'ftype',                 mapping:'ftype'},
                        {name: 'fname',                 mapping:'fname'},
                        {name: 'size',                  mapping:'size'},
                        {name: 'mtime',                 mapping:'mtime'},
                        {name: 'mode',                  mapping:'mode'}
                ]
            });

            //-----------------------------
            // Column model generation
            //-----------------------------
            var colModel = new Ext.grid.ColumnModel([
                {header: app_localized_message("label", "fname"), width: 200, locked:false, sortable: true, dataIndex: 'fname', id:'fname', renderer: this.onFnameRenderer.createDelegate(this)},
                {header: app_localized_message("label", "size"), width: 100, locked:false, sortable: true, dataIndex: 'size', renderer: this.onNumberRenderer.createDelegate(this) },
                {header: app_localized_message("label", "mtime"), width: 130, locked:false, sortable: true, dataIndex: 'mtime', renderer: this.onDateRenderer.createDelegate(this)}
            ]);

            //-----------------------------
            // Grid Generation
            //-----------------------------
            this.grid_list = new Ext.grid.GridPanel({
                el : 'file_index_file',
                ds: this.ds_list,
                cm: colModel,
                autoExpandColumn: 'fname',
                loadMask : true,
                monitorResize : true ,
                region: 'center',
                border : false,
                margins: '0 0 0 0'
            });
            this.grid_list.addListener( "rowcontextmenu", this.onGridRowContextMenu, this, null ) ;
            this.grid_list.addListener( "contextmenu", this.onGridContextMenu, this, null ) ;
            this.grid_list.addListener( "dblclick", this.onGridDbclick, this, null ) ;

            // Context menu generation
            this._createCenterContextMenu();

        },

        /*==================================================
         * Function Name：onFnameRenderer
         * Overview		：Renderer File name
         * Argument		：value            Mixed                       Data item name
         *       		：phash            Hash　                      			   Cell Information
         *       		：rec              Ext.data.Record             Data object row
         *       		：rowIndex         Number                      Row index
         *       		：cellIndex        Number                      Column index
         *       		：datastore        Ext.data.JsonStore          DataStore
         * Return Value	：No
         ==================================================*/
        onFnameRenderer : function(value, phash, rec, rowIndex, cellIndex, datastore){
            var image ="" ;
            var ftype = rec.get("ftype");
            if( ftype == "directory"){
                image = '<img src="' + url_for("images/icon/folder.gif") + '" class="x-tree-node-icon" align="absmiddle">&nbsp;' ;
            }
            else{
                image = '<img src="' + url_for("images/icon/leaf.gif") + '" class="x-tree-node-icon" align="absmiddle">&nbsp;' ;
            }
            
            return image + value ;
        },

        /*==================================================
         * Function Name：onNumberRenderer
         * Overview		：Numerical renderer
         * Argument		：value            Mixed                       
         *       		：phash            Hash　                      				
         *       		：rec              Ext.data.Record             
         *       		：rowIndex         Number                      
         *       		：cellIndex        Number                      
         *       		：datastore        Ext.data.JsonStore          
         * Return Value	：No
         ==================================================*/
        onNumberRenderer : function(value, phash, rec, rowIndex, cellIndex, datastore){
            var ret = money_format(value) ;
            return ret ;
        },

        /*==================================================
         * Function Name：onDateRenderer
         * Overview		：Date Renderer
         * Argument		：value            Mixed                       
         *       		：phash            Hash　                      
         *       		：rec              Ext.data.Record             
         *       		：rowIndex         Number                      
         *       		：cellIndex        Number                      
         *       		：datastore        Ext.data.JsonStore          
         * Return Value	：No
         ==================================================*/
        onDateRenderer : function(value, phash, rec, rowIndex, cellIndex, datastore){
            var ret = onDateChange(value) ;
            return ret ;
        },

        /** onGridRowContextMenu
         * Folder, right-click menu item in the list of files
         * 
         * @param Ext.grid.ColumnModel grid
         * @param Int rowIndex
         * @param Ext.EventObject e
         */
        onGridRowContextMenu : function(grid, rowIndex, e )
        {
            var rec = this.ds_list.getAt(rowIndex) ;
            if(rec.get('id') == 0 )  return false ;

            e.stopEvent();
            var row = e.getTarget() ;
            var pos = e.getXY() ;

            this.onGridRowContextMenu_select(rec, rowIndex, e);

            var ftype = rec.get("ftype");
            if( ftype == "directory"){
                this.ctxMenu_folder.showAt(pos);// 
            } else {
                this.ctxMenu_file.showAt(pos);// 
            }
        },

        /** onGridContextMenu
         * What happens when I right-clicked nothing
         */
        onGridContextMenu : function(e) {
            e.stopEvent();
            var pos = e.getXY();
            this.ctxMenu_none.showAt(pos);// 
        },

        onGridDbclick : function(){
            var selmodel = this.grid_list.getSelectionModel() ;
            var selrec = selmodel.getSelected() ;
            if (!selrec) return;
            var id = selrec.get('id');

            var ftype = selrec.get("ftype");
            if( ftype == "directory"){
                // Into folders
                this.current_node = id + '/' ;

                var selnode = this.tree_folder.getNodeById(this.current_node) ;
                selnode.loaded = false ;
                selnode.expand() ;
                selnode.select() ;

                this.load_data() ;

            } else {
                // Download
                this.fncDownloadFile();
            }

        },

        /**
         * Context menu generation
         */
        _createCenterContextMenu : function()
        {
            // Folder for
            this.ctxMenu_folder = new Ext.menu.Menu({id: this.tree_folder.id + "-hctx-folder"});
            this.ctxMenu_folder.add(
                {id:"row_folder_edit", text: "Name Change", cls: "grid-ctx-menu-edit"},
                {id:"row_folder_delete", text: "Delete", cls: "grid-ctx-menu-delete"}
            );
            this.ctxMenu_folder.on("itemclick", this.onGridRowContextMenuClick_folder, this);

            // Files for
            this.ctxMenu_file = new Ext.menu.Menu({id: this.grid_list.id + "-hctx-file"});
            this.ctxMenu_file.add(
                {id:"downloadfile", text: app_localized_message("label", "downloadfile"), cls: "grid-ctx-menu-download"},
                {id:"destroyfile", text: app_localized_message("label", "destroyfile"), cls: "grid-ctx-menu-destroy"}
            );
            this.ctxMenu_file.on("itemclick", this.onGridRowContextMenuClick_file, this);// 

            // 空白部分
            this.ctxMenu_none = new Ext.menu.Menu({id: this.grid_list.id + "-hctx-none"});
            this.ctxMenu_none.add(
                {id:"row_none_folder_new", text: app_localized_message("label", "newfolder"), cls: "grid-ctx-menu-newfolder"},
                {id:"row_none_file_new", text: app_localized_message("label", "uploadfile"), cls: "grid-ctx-menu-upload"},
                {id:"refresh", text: app_localized_message("label", "refresh"), cls: "grid-ctx-menu-refresh"}
            );
            this.ctxMenu_none.on("itemclick", this.onGridRowContextMenuClick_none, this);// 
        },

        onGridRowContextMenu_select : function(rec, rowIndex, e)
        {
            var selmodel = this.grid_list.getSelectionModel();
            selmodel.selectRow(rowIndex);
        },

        fncDownloadFile : function(){
            var selmodel = this.grid_list.getSelectionModel() ;
            var selrec = selmodel.getSelected() ;
            var id = selrec.get("id") ;

            var node = this.current_node ;

            var url = this.item_url_fi.replace('{:id}', '000');
            var form = Ext.get('projectfile_download') ;
            form.dom.action = url ;

            elm = Ext.get('projectfile_download_parent_node') ;
            elm.dom.value = node ;
            elm = Ext.get('projectfile_download_target_file') ;
            elm.dom.value = id ;
            elm = Ext.get('projectfile_download_browser_ie') ;
            elm.dom.value = Ext.isIE ? '1' : '0' ;
            form.dom.submit() ;
            return false ;

/*
            var opt = {
                url: url,
                form: 'projectfile_download',
                scope: this,
                method: 'get'
            }
            Ext.Ajax.request(opt);
*/
        },

        /** onGridRowContextMenuClick_folder
         * 
         * 
         * @param Hash
         * @param Ext.EventObject
         */
        onGridRowContextMenuClick_folder : function(item, e)
        {
            switch(item.id){
                case 'row_folder_delete'   : this.fncGetIdToDestroy(); break ;// 
                case 'row_folder_edit'     : this.fncFolderEdit(); break ;// 
            }
        },

        /** onGridRowContextMenuClick_file
         * 
         * @param Hash
         * @param e Ext.event
         */
        onGridRowContextMenuClick_file : function(item, e){
            switch( item.id ){
                case 'downloadfile' : this.fncDownloadFile(); break ;
                case 'destroyfile'  : this.fncGetIdToDestroy(); break ;
            }
        },

        /** onGridRowContextMenuClick_none
         * 
         * @param Hash
         * @param e Ext.event
         */
        onGridRowContextMenuClick_none : function(item, e)
        {
            switch(item.id){
                case 'row_none_folder_new' : this.fncFolderNew(); break ;
                case 'row_none_file_new'   : this.fncFileNew(); break ;
                case 'refresh'             : this.load_list() ; break ;
            }
        },

        /*==================================================
         * Function Name：fncFolderNew
         * Overview：Prompting for file folders information
         * Argument：No
         * Return Value：No
         ==================================================*/
        fncFolderNew : function(){
            var selmdl = this.tree_folder.getSelectionModel() ;
            var selnode = selmdl.getSelectedNode() ;
            if (selnode.id == '0') this.current_node = 0;
            
            // Get the current path
            var node = this.current_node ;

            $mo.fire('open_projects_folder_edit_dialog', {parent_node: node, fname : null});
        },

        /*==================================================
         * Function Name：fncFolderEdit
         * Overview：for the main list
         * Argument：No
         * Return Value：No
         ==================================================*/
        fncFolderEdit : function(){
            var selmodel = this.grid_list.getSelectionModel() ;
            var selrec = selmodel.getSelected() ;
            var id = selrec.get("id") ;
            var fname = selrec.get("fname") ;
            this.fncDoEditFolder(id, fname);
        },

        fncDoEditFolder : function(id, fname){
            // Get the current path
            var node = this.current_node ;
            $mo.fire('open_projects_folder_edit_dialog', {parent_node: node, fname: fname, folder_id: id});
        },

        /*==================================================
         * Function Name：fncFileNew
         * Overview：Prompting for File Info
         * Argument：No
         * Return Value：No
         ==================================================*/
        fncFileNew : function(){
            // Get the current path
            var node = this.current_node ;
            $mo.fire('open_projects_file_edit_dialog', {parent_node: node});

        },

        fncGetIdToDestroy : function(){
            var selmodel = this.grid_list.getSelectionModel() ;
            var selrec = selmodel.getSelected() ;
            var id = selrec.get("id") ;

            this.fncDestroyFile(id);
        },

        fncDestroyFile : function(id){
            // @TODO: Data removal process
            if (confirm(this.messages.deleted)) {
                Ext.get('file_target_file').dom.value = id;
                var url = this.item_url_fi.replace('{:id}', '000');
                var opt = {
                    url: url,
                    form: 'file_target_file_form',
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
                this.load_list();
            } else {
                alert(message);
            }
        },

        onDestroyFail: function(r) {
            var message = $mo.decode(r.responseText).message;
            alert(message);
        },

        /*==================================================
         * Function Name：fncCreateLeftLayout
         * Overview：The left side of the page to generate layout
         * Argument：No
         * Return Value：No
         ==================================================*/
        fncCreateLeftLayout : function(){
            var elmmain = Ext.get( 'file_index_folder_area') ;
            this.left_panel = new Ext.Container({
                applyTo : elmmain,
                layout : 'border',
                monitorResize : true,
                border : true,
                items: [
                    this.tree_folder
                ]
            }) ;
        },

        /*==================================================
         * Function Name：fncCreateCenterLayout
         * Overview：The center of the page to generate layout
         * Argument：No
         * Return Value：No
         ==================================================*/
        fncCreateCenterLayout : function(){
            var elmmain = Ext.get( 'file_index_file_area') ;
            this.center_panel = new Ext.Container({
                applyTo : elmmain,
                layout : 'border',
                monitorResize : true,
                border : true,
                items: [
                    this.grid_list
                ]
            }) ;
        }
    };
    
    var panel = new panel(id, p_cd, p_name);
}

$.fn.projects_files_grid = components.projects.files_grid;

})(jQuery, Motto);
