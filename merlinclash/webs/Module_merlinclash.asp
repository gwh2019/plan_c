<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<html xmlns:v>
<head>
<meta http-equiv="X-UA-Compatible" content="IE=Edge"/>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta HTTP-EQUIV="Pragma" CONTENT="no-cache">
<meta HTTP-EQUIV="Expires" CONTENT="-1">
<link rel="shortcut icon" href="images/favicon.png">
<link rel="icon" href="images/favicon.png">
<title>【Merlin Clash】</title>
<link rel="stylesheet" type="text/css" href="index_style.css">
<link rel="stylesheet" type="text/css" href="form_style.css">
<link rel="stylesheet" type="text/css" href="usp_style.css">
<link rel="stylesheet" type="text/css" href="css/element.css">
<link rel="stylesheet" type="text/css" href="/device-map/device-map.css">
<link rel="stylesheet" type="text/css" href="/js/table/table.css">
<link rel="stylesheet" type="text/css" href="/res/layer/theme/default/layer.css">
<link rel="stylesheet" type="text/css" href="/res/softcenter.css">
<link rel="stylesheet" type="text/css" href="/res/merlinclash.css">
<script type="text/javascript" src="/state.js"></script>
<script type="text/javascript" src="/popup.js"></script>
<script type="text/javascript" src="/help.js"></script>
<script type="text/javascript" src="/js/jquery.js"></script>
<script type="text/javascript" src="/general.js"></script>
<script type="text/javascript" language="JavaScript" src="/js/table/table.js"></script>
<script type="text/javascript" language="JavaScript" src="/client_function.js"></script>
<script type="text/javascript" src="/res/mc-menu.js"></script>
<script type="text/javascript" src="/res/softcenter.js"></script>
<script type="text/javascript" src="/res/mc-tablednd.js"></script>
<script type="text/javascript" src="/help.js"></script>
<script type="text/javascript" src="/switcherplugin/jquery.iphone-switch.js"></script>
<script type="text/javascript" src="/validator.js"></script>
<script>
var db_merlinclash={};
var _responseLen;
var x = 5;
var noChange = 0;
var node_max = 0;

function init() {
	show_menu(menu_hook);
	get_dbus_data();
	yaml_select();
	clashbinary_select();
	refresh_pgnodes_table();
	proxies_select();
	proxygroup_select();
	yaml_view();
	get_log();
	refresh_kcp_table();
	check_unblockneteasemusic_status();	
	if(E("merlinclash_enable").checked){
		merlinclash.checkIP();
	}
}

function get_dbus_data() {
	$.ajax({
		type: "GET",
		url: "dbconf?p=merlinclash_",
		dataType: "script",
		success: function(data) {
			db_merlinclash = db_merlinclash_;
			E("merlinclash_enable").checked = db_merlinclash["merlinclash_enable"] == "1";
			E("merlinclash_watchdog").checked = db_merlinclash["merlinclash_watchdog"] == "1";
			E("merlinclash_kcpswitch").checked = db_merlinclash["merlinclash_kcpswitch"] == "1";
			E("merlinclash_ipv6switch").checked = db_merlinclash["merlinclash_ipv6switch"] == "1";
			//E("merlinclash_nmswitch").checked = db_merlinclash["merlinclash_nmswitch"] == "1";
			E("merlinclash_unblockmusic_enable").checked = db_merlinclash["merlinclash_unblockmusic_enable"] == "1";
			if(db_merlinclash["merlinclash_unblockmusic_endpoint"]){
				E("merlinclash_unblockmusic_endpoint").value = db_merlinclash["merlinclash_unblockmusic_endpoint"];
			}
			if(db_merlinclash["merlinclash_unblockmusic_musicapptype"]){
				E("merlinclash_unblockmusic_musicapptype").value = db_merlinclash["merlinclash_unblockmusic_musicapptype"];
			}
			//E("merlinclash_kpswitch").checked = db_merlinclash["merlinclash_kpswitch"] == "1";
			//E("merlinclash_udpr").checked = db_merlinclash["merlinclash_udpr"] == "1";
			E("merlinclash_unblockmusic_bestquality").checked = db_merlinclash["merlinclash_unblockmusic_bestquality"] == "1";			
			if(db_merlinclash["merlinclash_links"]){					
				E("merlinclash_links").value = db_merlinclash["merlinclash_links"];
			}
			if(db_merlinclash["merlinclash_links2"]){					
				E("merlinclash_links2").value = db_merlinclash["merlinclash_links2"];
			}
			if(db_merlinclash["merlinclash_links3"]){
				var delinks2 = decodeURIComponent(db_merlinclash["merlinclash_links3"]);
				E("merlinclash_links3").value = delinks2;
			}
			if(db_merlinclash["merlinclash_dnsplan"]){					
				$("input:radio[name='dnsplan'][value="+db_merlinclash["merlinclash_dnsplan"]+"]").attr('checked','true');
			}
			//$("input:radio[name='dnsplan'][value="+db_merlinclash["merlinclash_dnsplan"]+"]").attr('checked','true');
			//alert(db_merlinclash["merlinclash_yamlsel"]);
			//E("merlinclash_yamlsel").value = db_merlinclash["merlinclash_yamlsel"];
			if(db_merlinclash["merlinclash_yamlsel"]){					
				$("#merlinclash_yamlsel").append("<option value='"+db_merlinclash["merlinclash_yamlsel"]+"' >"+db_merlinclash["merlinclash_yamlsel"]+"</option>");
			
			}			
			toggle_func();
			get_clash_status_front();
			gethost();				
			dnsfiles();				
			version_show();
			refresh_acl_table();
		}
	});
}

var yamlsel_tmp2;
function quickly_restart() {
	if(!$.trim($('#merlinclash_yamlsel').val())){
		alert("必须选择一个配置文件！");
		return false;
	}
	//var radio = document.getElementsByName("dnsplan").innerHTML = getradioval();
	//db_merlinclash["merlinclash_enable"] = E("merlinclash_enable").checked ? '1' : '0';
	//db_merlinclash["merlinclash_watchdog"] = E("merlinclash_watchdog").checked ? '1' : '0';
	//db_merlinclash["merlinclash_kcpswitch"] = E("merlinclash_kcpswitch").checked ? '1' : '0';
	//db_merlinclash["merlinclash_ipv6switch"] = E("merlinclash_ipv6switch").checked ? '1' : '0';
	//db_merlinclash["merlinclash_nmswitch"] = E("merlinclash_nmswitch").checked ? '1' : '0';
	//db_merlinclash["merlinclash_unblockmusic_enable"] = E("merlinclash_unblockmusic_enable").checked ? '1' : '0';
	//db_merlinclash["merlinclash_unblockmusic_endpoint"] = E("merlinclash_unblockmusic_endpoint").value;
	//db_merlinclash["merlinclash_unblockmusic_musicapptype"] = E("merlinclash_unblockmusic_musicapptype").value;
	
	//db_merlinclash["merlinclash_kpswitch"] = E("merlinclash_kpswitch").checked ? '1' : '0';
	//db_merlinclash["merlinclash_dnsplan"] = radio;
	//db_merlinclash["merlinclash_links"] = E("merlinclash_links").value;
	//db_merlinclash["merlinclash_links2"] = E("merlinclash_links2").value;
	//URL编码后再传入后端
	//var links3 = encodeURIComponent(E("merlinclash_links3").value);
	//db_merlinclash["merlinclash_links3"] = links3;
	//db_merlinclash["merlinclash_udpr"] = E("merlinclash_udpr").checked ? '1' : '0';
	//db_merlinclash["merlinclash_yamlsel"] = E("merlinclash_yamlsel").value;
	yamlsel_tmp1 = E("merlinclash_yamlsel").value;
	//db_merlinclash["merlinclash_delyamlsel"] = E("merlinclash_delyamlsel").value;
	//20200630+++
	//db_merlinclash["merlinclash_acl4ssrsel"] = E("merlinclash_acl4ssrsel").value;
	//20200630---	
	//自定规则
	//if(E("ACL_table")){
	//	var tr = E("ACL_table").getElementsByTagName("tr");
	//	//for (var i = 1; i < tr.length - 1; i++) {
	//	for (var i = 1; i < tr.length ; i++) {	
	//		var rowid = tr[i].getAttribute("id").split("_")[2];
	//		if (E("merlinclash_acl_type_" + i)){
	//			db_merlinclash["merlinclash_acl_type_" + rowid] = E("merlinclash_acl_type_" + rowid).value;
	//			db_merlinclash["merlinclash_acl_content_" + rowid] = E("merlinclash_acl_content_" + rowid).value;
	//			db_merlinclash["merlinclash_acl_lianjie_" + rowid] = E("merlinclash_acl_lianjie_" + rowid).value;					
	//		}else{
	//			
	//		}				
	//	}
	//}else{
		
	//}
	//KCP
	//if(E("KCP_table")){
	//	var tr = E("KCP_table").getElementsByTagName("tr");
	//	//for (var i = 1; i < tr.length - 1; i++) {
	//	for (var i = 1; i < tr.length ; i++) {	
	//		var rowid = tr[i].getAttribute("id").split("_")[2];
	//		if (E("merlinclash_kcp_lport_" + i)){
	//			db_merlinclash["merlinclash_kcp_lport_" + rowid] = E("merlinclash_kcp_lport_" + rowid).value;
	//			db_merlinclash["merlinclash_kcp_server_" + rowid] = E("merlinclash_kcp_server_" + rowid).value;
	//			db_merlinclash["merlinclash_kcp_port_" + rowid] = E("merlinclash_kcp_port_" + rowid).value;
	//			db_merlinclash["merlinclash_kcp_param_" + rowid] = E("merlinclash_kcp_param_" + rowid).value;
	//		}else{
	//			
	//		}				
	//	}
	//}else{

//	}
	var act;
	//if(E("merlinclash_enable").checked){ 
			//act = "start";
			db_merlinclash["merlinclash_action"] = "1";
			//alert('bbb');
	//}else{
			//act = "stop";
	//		db_merlinclash["merlinclash_action"] = "0";
			//alert('ccc');
	//}
	//var id = parseInt(Math.random() * 100000000);
	//var postData = {"id": id, "method": "clash_status.sh", "params":[], "fields": ""};
	$.ajax({
		url: "/logreaddb.cgi?p=merlinclash.log&script=clash_status.sh",
		dataType: 'html',
		success: function(response) {
			var arr = response.split("@");			
			if (arr[0] == "" || arr[1] == "") {
				
			} else {
				yamlsel_tmp2 = arr[7];
				//更换配置文件，清空节点指定内容
				if(yamlsel_tmp2==null){
					yamlsel_tmp2=yamlsel_tmp1
					
				}
				if(yamlsel_tmp2!=yamlsel_tmp1){
					alert("切换配置不能直接快速重启");
					refreshpage();
					return false;						
				}
				push_data("clash_config.sh", "restart",  db_merlinclash);
			}
		}
	});	
	
}
function apply() {
	if(!$.trim($('#merlinclash_yamlsel').val())){
		alert("必须选择一个配置文件！");
		return false;
	}
	var radio = document.getElementsByName("dnsplan").innerHTML = getradioval();
	db_merlinclash["merlinclash_enable"] = E("merlinclash_enable").checked ? '1' : '0';
	db_merlinclash["merlinclash_watchdog"] = E("merlinclash_watchdog").checked ? '1' : '0';
	db_merlinclash["merlinclash_kcpswitch"] = E("merlinclash_kcpswitch").checked ? '1' : '0';
	db_merlinclash["merlinclash_ipv6switch"] = E("merlinclash_ipv6switch").checked ? '1' : '0';
	//db_merlinclash["merlinclash_nmswitch"] = E("merlinclash_nmswitch").checked ? '1' : '0';
	db_merlinclash["merlinclash_unblockmusic_enable"] = E("merlinclash_unblockmusic_enable").checked ? '1' : '0';
	db_merlinclash["merlinclash_unblockmusic_endpoint"] = E("merlinclash_unblockmusic_endpoint").value;
	db_merlinclash["merlinclash_unblockmusic_musicapptype"] = E("merlinclash_unblockmusic_musicapptype").value;
	
	//db_merlinclash["merlinclash_kpswitch"] = E("merlinclash_kpswitch").checked ? '1' : '0';
	db_merlinclash["merlinclash_dnsplan"] = radio;
	db_merlinclash["merlinclash_links"] = E("merlinclash_links").value;
	db_merlinclash["merlinclash_links2"] = E("merlinclash_links2").value;
	//URL编码后再传入后端
	var links3 = encodeURIComponent(E("merlinclash_links3").value);
	db_merlinclash["merlinclash_links3"] = links3;
	//db_merlinclash["merlinclash_udpr"] = E("merlinclash_udpr").checked ? '1' : '0';
	db_merlinclash["merlinclash_unblockmusic_bestquality"] = E("merlinclash_unblockmusic_bestquality").checked ? '1' : '0';
	db_merlinclash["merlinclash_yamlsel"] = E("merlinclash_yamlsel").value;
	yamlsel_tmp1 = E("merlinclash_yamlsel").value;
	db_merlinclash["merlinclash_delyamlsel"] = E("merlinclash_delyamlsel").value;
	//20200630+++
	db_merlinclash["merlinclash_acl4ssrsel"] = E("merlinclash_acl4ssrsel").value;
	//20200630---	
	//自定规则
	if(E("ACL_table")){
		var tr = E("ACL_table").getElementsByTagName("tr");
		//for (var i = 1; i < tr.length - 1; i++) {
		for (var i = 1; i < tr.length ; i++) {	
			var rowid = tr[i].getAttribute("id").split("_")[2];
			if (E("merlinclash_acl_type_" + i)){
				db_merlinclash["merlinclash_acl_type_" + rowid] = E("merlinclash_acl_type_" + rowid).value;
				db_merlinclash["merlinclash_acl_content_" + rowid] = E("merlinclash_acl_content_" + rowid).value;
				db_merlinclash["merlinclash_acl_lianjie_" + rowid] = E("merlinclash_acl_lianjie_" + rowid).value;
			}				
		}
	}
	//KCP
	if(E("KCP_table")){
		var tr = E("KCP_table").getElementsByTagName("tr");
		//for (var i = 1; i < tr.length - 1; i++) {
		for (var i = 1; i < tr.length ; i++) {	
			var rowid = tr[i].getAttribute("id").split("_")[2];
			if (E("merlinclash_kcp_lport_" + i)){
				db_merlinclash["merlinclash_kcp_lport_" + rowid] = E("merlinclash_kcp_lport_" + rowid).value;
				db_merlinclash["merlinclash_kcp_server_" + rowid] = E("merlinclash_kcp_server_" + rowid).value;
				db_merlinclash["merlinclash_kcp_port_" + rowid] = E("merlinclash_kcp_port_" + rowid).value;
				db_merlinclash["merlinclash_kcp_param_" + rowid] = E("merlinclash_kcp_param_" + rowid).value;
			}				
		}
	}
	var act;
	if(E("merlinclash_enable").checked){ 
			//act = "start";
			db_merlinclash["merlinclash_action"] = "1";
			//alert('bbb');
	}else{
			//act = "stop";
			db_merlinclash["merlinclash_action"] = "0";
			//alert('ccc');
	}
	//var id = parseInt(Math.random() * 100000000);
	//var postData = {"id": id, "method": "clash_status.sh", "params":[], "fields": ""};
	$.ajax({
		url: "/logreaddb.cgi?p=merlinclash.log&script=clash_status.sh",
		dataType: 'html',

		success: function(response) {
			var arr = response.split("@");			
			if (arr[0] == "" || arr[1] == "") {
				
			} else {
				yamlsel_tmp2 = arr[7];
				//更换配置文件，清空节点指定内容
				if(yamlsel_tmp2==null){
					yamlsel_tmp2=yamlsel_tmp1
					
				}
				if(yamlsel_tmp2!=yamlsel_tmp1){
					apply_delallpgnodes();
					db_merlinclash["merlinclash_action"] = "1";
					
				}
				push_data("clash_config.sh", "start",  db_merlinclash);
			}
		}
	});
}
function push_data(script, arg, obj, flag){
	if (!flag) showMCLoadingBar();
	//var id = parseInt(Math.random() * 100000000);
	//var postData = {"id": id, "method": script, "params":[arg], "fields": obj};
	obj["action_script"] = script;
	obj["action_mode"] = arg;
	$.ajax({
		type: "POST",
		url: "/applydb.cgi?p=merlinclash",
		data: $.param(obj),
		dataType: "text",
		success: function(response){
			//alert(flag);
			//if(response.result == id){
				if(flag && flag == "1"){
					refreshpage();
				}else if(flag && flag == "2"){
					//continue;
					//do nothing
				}else{
					//alert('get');
					get_realtime_log();
				}
			//}
		}
	});
}
function tabSelect(w) {
	for (var i = 0; i <= 10; i++) {
		$('.show-btn' + i).removeClass('active');
		$('#tablet_' + i).hide();
	}
	$('.show-btn' + w).addClass('active');
	$('#tablet_' + w).show();
}
function dingyue() {
tabSelect(1);
$('#apply_button').hide(); 	
$('#delallpgnodes_button').hide();
}
function toggle_func() {
	//$("#merlinclash_enable").click(
	//function() {
	//	""
	//});
	$(".show-btn0").click(
		function() {
			tabSelect(0);
			$('#apply_button').show(); 
			$('#delallpgnodes_button').hide(); 			
		});
	$(".show-btn1").click( 
		function() {
			tabSelect(1);
			$('#apply_button').hide(); 
			$('#delallpgnodes_button').hide();
		});
	$(".show-btn2").click(
		function() {
			tabSelect(2);
			$('#apply_button').show();
			$('#delallpgnodes_button').hide();
			//refresh_acl_table();
		});
	$(".show-btn3").click(
		function() {
			tabSelect(3);
			$('#apply_button').show(); 
			$('#delallpgnodes_button').hide();
		});
	$(".show-btn4").click(
		function() {
			if(db_merlinclash["merlinclash_updata_date"]){
				E("geoip_updata_date").innerHTML = "<span style='color: gold'>上次更新时间："+db_merlinclash["merlinclash_updata_date"]+"</span>";
			}
			//if(db_merlinclash["merlinclash_update_clashdate"]){
			//	E("clash_update_date").innerHTML = "<span style='color: gold'>&nbsp;&nbsp;上次更新时间："+db_merlinclash["merlinclash_update_clashdate"]+"</span>";
			//}
			tabSelect(4);
			$('#apply_button').hide();
			$('#delallpgnodes_button').hide();
		});
	$(".show-btn5").click(
		function() {
			tabSelect(5);
			$('#apply_button').hide();
			$('#delallpgnodes_button').hide();
		});
	$(".show-btn6").click(
		function() {
			tabSelect(6);
			$('#apply_button').hide();
			$('#delallpgnodes_button').hide();
		});
	$(".show-btn7").click(
		function() {
			tabSelect(7);
			$('#apply_button').show();
			$('#delallpgnodes_button').show();		
		});
        $(".show-btn8").click(
		function() {
			tabSelect(8);
			$('#apply_button').show();
			$('#delallpgnodes_button').hide(); 
		});
	//显示默认页
	$(".show-btn0").trigger("click");

}
function get_clash_status_front() {
	if (db_merlinclash['merlinclash_enable'] != "1") {
		E("clash_state2").innerHTML = "clash进程 - " + "Waiting...";
		E("clash_state3").innerHTML = "看门狗进程 - " + "Waiting...";
		E("dashboard_state2").innerHTML = "面板host";
		E("dashboard_state3").innerHTML = "面板端口";
		return false;
	}
	//var id = parseInt(Math.random() * 100000000);
	//var postData = {"id": id, "method": "clash_status.sh", "params":[], "fields": ""};
	$.ajax({
		url: "/logreaddb.cgi?p=merlinclash.log&script=clash_status.sh",
		dataType: 'html',
		success: function(response) {
			var arr = response.split("@");
			
			if (arr[0] == "" || arr[1] == "") {
				E("clash_state2").innerHTML = "clash进程 - " + "Waiting for first refresh...";
				E("clash_state3").innerHTML = "看门狗进程 - " + "Waiting for first refresh...";
				E("dashboard_state2").innerHTML = "面板host";
				E("dashboard_state3").innerHTML = "面板端口";
			} else {
				E("clash_state2").innerHTML = arr[0];
				E("clash_state3").innerHTML = arr[1];
				E("dashboard_state2").innerHTML = arr[5];
				E("dashboard_state3").innerHTML = arr[6];
				yamlsel_tmp2 = arr[7];
			}
		}
	});

	setTimeout("get_clash_status_front();", 10000);
}
function get_clash_nodes_proxygroup_front() {
	//var id = parseInt(Math.random() * 100000000);
	//var postData = {"id": id, "method": "clash_nodesproxygroup.sh", "params":[], "fields": ""};
	$.ajax({
		url: "/logreaddb.cgi?p=clash_proc_status.txt&script=clash_nodesproxygroup.sh",
		async: true,
		data: JSON.stringify(postData),
		success: function(response) {
			
		}
	});

	setTimeout("get_clash_nodes_proxygroup_front();", 10000);
}
function close_proc_status() {
	$("#detail_status").fadeOut(200);
}
function get_proc_status() {
	$("#detail_status").fadeIn(500);
	//var id = parseInt(Math.random() * 100000000);
	//var postData = {"id": id, "method": "clash_proc_status.sh", "params":[], "fields": ""};
	$.ajax({
		url: "/logreaddb.cgi?p=clash_proc_status.txt&script=clash_proc_status.sh",
		dataType: 'html',
		success: function(res) {
			$('#proc_status').val(res);
		}
	});
}

function get_online_yaml(action) {
	var dbus_post = {};
	if(!$.trim($('#merlinclash_links').val())){
        alert("订阅链接不能为空！");
        return false;
	}
	dbus_post["merlinclash_links"] = db_merlinclash["merlinclash_links"] = (E("merlinclash_links").value);
	dbus_post["merlinclash_uploadrename"] = db_merlinclash["merlinclash_uploadrename"] = (E("merlinclash_uploadrename").value);
	dbus_post["merlinclash_action"] = db_merlinclash["merlinclash_action"] = action;
	push_data("clash_online_yaml.sh", "restart",  dbus_post);
	
}
function get_online_yaml2(action) {
		var dbus_post = {};
		if(!$.trim($('#merlinclash_links2').val())){
			alert("订阅链接不能为空！");
			return false;
		}
		dbus_post["merlinclash_links2"] = db_merlinclash["merlinclash_links2"] = (E("merlinclash_links2").value);
		dbus_post["merlinclash_uploadrename2"] = db_merlinclash["merlinclash_uploadrename2"] = (E("merlinclash_uploadrename2").value);
		dbus_post["merlinclash_action"] = db_merlinclash["merlinclash_action"] = action;
		push_data("clash_online_yaml2.sh", "restart",  dbus_post);
		
}
function get_online_yaml3(action) {
	var dbus_post = {};
	if(!$.trim($('#merlinclash_links3').val())){
		alert("订阅链接不能为空！");
		return false;
	}
	var links3 = encodeURIComponent(E("merlinclash_links3").value);
	//alert(links3);
	dbus_post["merlinclash_links3"] = db_merlinclash["merlinclash_links3"] = links3;
	dbus_post["merlinclash_uploadrename4"] = db_merlinclash["merlinclash_uploadrename4"] = (E("merlinclash_uploadrename4").value);
	dbus_post["merlinclash_action"] = db_merlinclash["merlinclash_action"] = action;
	//20200630+++
	dbus_post["merlinclash_acl4ssrsel"] = db_merlinclash["merlinclash_acl4ssrsel"] = E("merlinclash_acl4ssrsel").value;
	//20200630---
	push_data("clash_online_yaml4.sh", "restart",  dbus_post);
	
}
function ssconvert(action) {
	var dbus_post = {};
	dbus_post["merlinclash_uploadrename3"] = db_merlinclash["merlinclash_uploadrename3"] = (E("merlinclash_uploadrename3").value);
	dbus_post["merlinclash_action"] = db_merlinclash["merlinclash_action"] = action;
	push_data("clash_online_yaml3.sh", "restart",  dbus_post);
}
function del_yaml_sel(action) {
	var dbus_post = {};
	if(!$.trim($('#merlinclash_delyamlsel').val())){
		alert("配置文件不能为空！");
		return false;
	}
	if(E("merlinclash_delyamlsel").value == db_merlinclash["merlinclash_yamlsel"]){
		alert("选择的配置文件为当前使用文件，不予删除！");
		return false;
	}
	dbus_post["merlinclash_delyamlsel"] = db_merlinclash["merlinclash_delyamlsel"] = (E("merlinclash_delyamlsel").value);
	dbus_post["merlinclash_action"] = db_merlinclash["merlinclash_action"] = "4"
	push_data("clash_delyamlsel.sh", "clean", dbus_post);
	//yaml_select();
}
function download_yaml_sel() {
	//下载前清空/tmp文件夹下的yaml格式文件	
	if(!$.trim($('#merlinclash_delyamlsel').val())){
		alert("配置文件不能为空！");
		return false;
	}
	var dbus_post = {};
	clear_yaml();
	dbus_post["merlinclash_delyamlsel"] = db_merlinclash["merlinclash_delyamlsel"] = (E("merlinclash_delyamlsel").value);
	//alert(dbus_post["merlinclash_delyamlsel"]);
	//var id = parseInt(Math.random() * 100000000);
	//var postData = {"id": id, "method": "clash_downyamlsel.sh", "params":[], "fields": dbus_post};
	dbus_post["action_script"] = "clash_downyamlsel.sh";
	dbus_post["action_mode"] = " Refresh ";
	var yamlname=""
	$.ajax({
		type: "POST",
		url: "/applydb.cgi?p=merlinclash",
		data: $.param(dbus_post),
		dataType: "text",
		success: function(response) {
			yamlname = dbus_post["merlinclash_delyamlsel"] + ".json";
			//alert(yamlname);
			download(yamlname);
		}
	});
}
function download(yamlname) {
	var downloadA = document.createElement('a');
	var josnData = {};
	var a = "http://"+window.location.hostname+"/ext/"+yamlname
	var blob = new Blob([JSON.stringify(josnData)],{type : 'application/json'});
	downloadA.href = a;
	downloadA.download = db_merlinclash["merlinclash_delyamlsel"] + ".yaml";
	downloadA.click();
	window.URL.revokeObjectURL(downloadA.href);
}
function yaml_view() {
$.ajax({
		url: '/logreaddb.cgi?p=view.txt',
		dataType: 'html',
		success: function(response) {
			var retArea = E("yaml_content1");
			if (response.search("BBABBBBC") != -1) {
				retArea.value = response.replace("BBABBBBC", " ");
				var pageH = parseInt(E("FormTitle").style.height.split("px")[0]); 
				if(pageH){
					autoTextarea(E("yaml_content1"), 0, (pageH - 308));
				}else{
					autoTextarea(E("yaml_content1"), 0, 980);
				}
				return true;
			}
			if (_responseLen == response.length) {
				noChange++;
			} else {
				noChange = 0;
			}
			if (noChange > 5) {
				return false;
			} else {
				setTimeout("yaml_view();", 300);
			}
			retArea.value = response;
			_responseLen = response.length;
		},
		error: function(xhr) {
			E("yaml_content1").value = "获取配置文件信息失败！";
		}
	});
}
function get_log() {
	$.ajax({
		url: '/logreaddb.cgi?p=merlinclash_log.txt',
		dataType: 'html',
		success: function(response) {
			var retArea = E("log_content1");
			if (response.search("BBABBBBC") != -1) {
				retArea.value = response.replace("BBABBBBC", " ");
				var pageH = parseInt(E("FormTitle").style.height.split("px")[0]); 
				if(pageH){
					autoTextarea(E("log_content1"), 0, (pageH - 308));
				}else{
					autoTextarea(E("log_content1"), 0, 980);
				}
				return true;
			}
			if (_responseLen == response.length) {
				noChange++;
			} else {
				noChange = 0;
			}
			if (noChange > 5) {
				return false;
			} else {
				setTimeout("get_log();", 300);
			}
			retArea.value = response;
			_responseLen = response.length;
		},
		error: function(xhr) {
			E("log_content1").value = "获取日志失败！";
		}
	});
}
function count_down_close1() {
	if (x == "0") {
		hideMCLoadingBar();
	}
	if (x < 0) {
		E("ok_button1").value = "手动关闭"
		return false;
	}
	E("ok_button1").value = "自动关闭（" + x + "）"
		--x;
	setTimeout("count_down_close1();", 1000);
}
function get_realtime_log() {
	$.ajax({
		url: '/logreaddb.cgi?p=merlinclash_log.txt',
		dataType: 'html',
		success: function(response) {
			var retArea = E("log_content3");
			//alert(response.search("BBABBBBC"));
			//console.log(retArea);
			if (response.search("BBABBBBC") != -1) {
				retArea.value = response.replace("BBABBBBC", " ");
				E("ok_button").style.display = "";
				retArea.scrollTop = retArea.scrollHeight;
				count_down_close1();
				return true;
			}
			if (_responseLen == response.length) {
				noChange++;
			} else {
				noChange = 0;
			}
			if (noChange > 1000) {
				return false;
			} else {
				setTimeout("get_realtime_log();", 100);
			}
			retArea.value = response.replace("BBABBBBC", " ");
			retArea.scrollTop = retArea.scrollHeight;
			_responseLen = response.length;
		},
		error: function() {
			setTimeout("get_realtime_log();", 500);
		}
	});
}
function getradioval() {
	var radio = document.getElementsByName("dnsplan");
	for(i = 0; i< radio.length; i++){
		if(radio[i].checked){
			return radio[i].value
		}
	}
	var yamlsel = document.getElementsByName("yamlsel");
	for(i = 0; i< yamlsel.length; i++){
		if(yamlsel[i].checked){
			return yamlsel[i].value
		}
	}
}

function clear_yaml() {
	//var id = parseInt(Math.random() * 100000000);
	//var postData = {"id": id, "method": "clash_clearyaml.sh", "params":[], "fields": ""};
	var dbus_post = {};
	dbus_post["action_script"] = "clash_clearyaml.sh";
	dbus_post["action_mode"] = " Refresh ";
	$.ajax({
		type: "POST",
		url: "/applydb.cgi?p=merlinclash",
		data: $.param(dbus_post),
		dataType: "text",
		success: function(response) {
		}
	});
}

function upload_clashbinary() {

	if(!$.trim($('#clashbinary').val())){
		alert("请先选择clash文件");
		return false;
	}

	require(['/res/layer/layer.js'], function(layer) {
		layer.confirm('<li>请确保clash二进制文件合法！仍要替换clash吗？</li>', {
			shade: 0.8,
		}, function(index) {
			E('clashbinary_upload').style.display = "none";
			var formData = new FormData();
			formData.append("clash", document.getElementById('clashbinary').files[0]);
			$.ajax({
				url: 'ssupload.cgi?a=/tmp/clash',
				type: 'POST',
				cache: false,
				data: formData,
				processData: false,
				contentType: false,
				complete: function(res) {
					if (res.status == 200) {
						upload_binary();
					}
				}
			});
			layer.close(index);
			return true;			
		}, function(index) {
			layer.close(index);
			return false;
		});
	});
	
	
}
function upload_binary() {
	var dbus_post = {};
	action = dbus_post["merlinclash_action"] = db_merlinclash["merlinclash_action"] = "12"
	push_data("clash_local_binary_upload.sh", "start",  dbus_post);
	E('clashbinary_upload').style.display = "block";
}
//上传配置文件到/tmp文件夹
function upload_clashconfig() {
	var filename = $("#clashconfig").val();
	filename = filename.split('\\');
	filename = filename[filename.length - 1];
	var filelast = filename.split('.');
	filelast = filelast[filelast.length - 1];
	//alert(filename);
	if (filelast != "yaml") {
		alert('配置文件格式不正确！');
		return false;
	}
	E('clashconfig_info').style.display = "none";
	var formData = new FormData();
	
	formData.append(filename, document.getElementById('clashconfig').files[0]);
　　
	$.ajax({
		url: 'ssupload.cgi?a=/tmp/'+filename,
		type: 'POST',
		cache: false,
		data: formData,
		processData: false,
		contentType: false,
		complete: function(res) {
			if (res.status == 200) {
				upload_config(filename);
			}
		}
	});
}

//配置文件处理
function upload_config(filename) {
	var dbus_post = {};
	dbus_post["merlinclash_action"] = db_merlinclash["merlinclash_action"] = "3"
	dbus_post["merlinclash_uploadfilename"] = db_merlinclash["merlinclash_uploadfilename"] = filename;
	push_data("clash_config.sh", "clean",  dbus_post);
	E('clashconfig_info').style.display = "block";
	yaml_select();
}

function version_show() {
	if(!db_merlinclash["merlinclash_version_local"]) db_merlinclash["merlinclash_version_local"] = "0.0.0"
	$("#merlinclash_version_show").html("<a class='hintstyle'><i>当前版本：" + db_merlinclash['merlinclash_version_local'] + "</i></a>");
}

function gethost() {
	//var id = parseInt(Math.random() * 100000000);
	//var postData = {"id": id, "method": "clash_status.sh", "params":[], "fields": ""};
	$.ajax({
		url: "/logreaddb.cgi?p=merlinclash.log&script=clash_status.sh",
		dataType: 'html',
		success: function(response) {
			var arr = response.split("@");
			if (arr[2] == "") {

			} else {		
				//$("#yacd").html("<a href='http://yacd.haishan.me/?hostname=" + arr[2] + "&port=" + arr[3] + "'" + " target=_blank' id='razord' ><button type='button' class='ss-btn'>访问 YACD-Clash 面板</button></a>");
				//$("#yacd").html("<a type='button' href='http://yacd.haishan.me/?hostname=" + arr[2] + "&port=" + arr[3] + "'" + " target='_blank' >访问 YACD-Clash 面板</a>");
				$("#yacd").html("<a type='button' href='http://"+ arr[2] + "/ext/yacd/index.html?hostname=" + arr[2] + "&port=" + arr[3] + "'" + " target='_blank' >访问 YACD-Clash 面板</a>");
				//$("#yacd").html("<a type='button' style='vertical-align: middle;' id='yacd' class='ss_btn' style='cursor:pointer' href='http://yacd.haishan.me/?hostname=" + arr[2] + "&port=" + arr[3] + "'" + " target='_blank' >访问 YACD-Clash 面板</a>");
				$("#razord").html("<a type='button' href='http://"+ arr[2] + "/ext/razord/index.html' target='_blank' >访问 RAZORD-Clash 面板</a>");
			}
		}
	});
}
function dnsfilechange() {
	var dbus_post = {};
	dbus_post["merlinclash_rh_nameserver1"] = db_merlinclash["merlinclash_rh_nameserver1"] = E("merlinclash_rh_nameserver1").value;
	dbus_post["merlinclash_rh_nameserver2"] = db_merlinclash["merlinclash_rh_nameserver2"] = E("merlinclash_rh_nameserver2").value;
	dbus_post["merlinclash_rh_nameserver3"] = db_merlinclash["merlinclash_rh_nameserver3"] = E("merlinclash_rh_nameserver3").value;
	dbus_post["merlinclash_rh_fallback1"] = db_merlinclash["merlinclash_rh_fallback1"] = E("merlinclash_rh_fallback1").value;
	dbus_post["merlinclash_rh_fallback2"] = db_merlinclash["merlinclash_rh_fallback2"] = E("merlinclash_rh_fallback2").value;
	dbus_post["merlinclash_rh_fallback3"] = db_merlinclash["merlinclash_rh_fallback3"] = E("merlinclash_rh_fallback3").value;
	
	dbus_post["merlinclash_rhp_nameserver1"] = db_merlinclash["merlinclash_rhp_nameserver1"] = E("merlinclash_rhp_nameserver1").value;
	dbus_post["merlinclash_rhp_nameserver2"] = db_merlinclash["merlinclash_rhp_nameserver2"] = E("merlinclash_rhp_nameserver2").value;
	dbus_post["merlinclash_rhp_nameserver3"] = db_merlinclash["merlinclash_rhp_nameserver3"] = E("merlinclash_rhp_nameserver3").value;
	dbus_post["merlinclash_rhp_fallback1"] = db_merlinclash["merlinclash_rhp_fallback1"] = E("merlinclash_rhp_fallback1").value;
	dbus_post["merlinclash_rhp_fallback2"] = db_merlinclash["merlinclash_rhp_fallback2"] = E("merlinclash_rhp_fallback2").value;
	dbus_post["merlinclash_rhp_fallback3"] = db_merlinclash["merlinclash_rhp_fallback3"] = E("merlinclash_rhp_fallback3").value;
	
	dbus_post["merlinclash_fi_nameserver1"] = db_merlinclash["merlinclash_fi_nameserver1"] = E("merlinclash_fi_nameserver1").value;
	dbus_post["merlinclash_fi_nameserver2"] = db_merlinclash["merlinclash_fi_nameserver2"] = E("merlinclash_fi_nameserver2").value;
	dbus_post["merlinclash_fi_nameserver3"] = db_merlinclash["merlinclash_fi_nameserver3"] = E("merlinclash_fi_nameserver3").value;
	dbus_post["merlinclash_fi_fallback1"] = db_merlinclash["merlinclash_fi_fallback1"] = E("merlinclash_fi_fallback1").value;
	dbus_post["merlinclash_fi_fallback2"] = db_merlinclash["merlinclash_fi_fallback2"] = E("merlinclash_fi_fallback2").value;
	dbus_post["merlinclash_fi_fallback3"] = db_merlinclash["merlinclash_fi_fallback3"] = E("merlinclash_fi_fallback3").value;
	//var id = parseInt(Math.random() * 100000000);
	//var postData = {"id": id, "method": "clash_dnsfilechange.sh", "params":[], "fields": dbus_post};
	dbus_post["action_script"] = "clash_dnsfilechange.sh";
	dbus_post["action_mode"] = " Refresh ";
	$.ajax({
		type: "POST",
		url: "/applydb.cgi?p=merlinclash",
		data: $.param(dbus_post),
		dataType: "text",
		error: function(xhr) {
			
		},
		success: function(response) {
			refreshpage();	
		}
	});
}
function dnsfiles() {
	//var id = parseInt(Math.random() * 100000000);
	//var postData = {"id": id, "method": "clash_dnsfiles.sh", "params":[], "fields": ""};
	$.ajax({
		url: "/logreaddb.cgi?p=dnsfiles.log&script=clash_dnsfiles.sh",
		dataType: 'html',
		success: function(response) {
			var arr = response.split("@");			
			E("merlinclash_rh_nameserver1").value = arr[0];
			E("merlinclash_rh_nameserver2").value = arr[1];
			E("merlinclash_rh_nameserver3").value = arr[2];
			E("merlinclash_rh_fallback1").value = arr[3];
			E("merlinclash_rh_fallback2").value = arr[4];
			E("merlinclash_rh_fallback3").value = arr[5];
			E("merlinclash_rhp_nameserver1").value = arr[6];
			E("merlinclash_rhp_nameserver2").value = arr[7];
			E("merlinclash_rhp_nameserver3").value = arr[8];
			E("merlinclash_rhp_fallback1").value = arr[9];
			E("merlinclash_rhp_fallback2").value = arr[10];
			E("merlinclash_rhp_fallback3").value = arr[11];
			E("merlinclash_fi_nameserver1").value = arr[12];
			E("merlinclash_fi_nameserver2").value = arr[13];
			E("merlinclash_fi_nameserver3").value = arr[14];
			E("merlinclash_fi_fallback1").value = arr[15];
			E("merlinclash_fi_fallback2").value = arr[16];
			E("merlinclash_fi_fallback3").value = arr[17];
		}
	});
}
function check_unblockneteasemusic_status(){
	//var id = parseInt(Math.random() * 100000000);
	//var postData = {"id": id, "method": "clash_unblockmusic_status.sh", "params":[], "fields": ""};
	$.ajax({
		url: "/logreaddb.cgi?p=unblockmusic_status.log&script=clash_unblockmusic_status.sh",
		dataType: 'html',
		success: function (response) {
			var arr = response.split("@");
			E("merlinclash_unblockmusic_status").innerHTML = arr[1];
			E("merlinclash_unblockmusic_version").innerHTML = arr[0];
							
			setTimeout("check_unblockneteasemusic_status();", 10000);
		},
		error: function(){
			E("merlinclash_unblockmusic_status").innerHTML = "获取运行状态失败";
			E("merlinclash_unblockmusic_version").innerHTML = "获取插件版本失败";
			setTimeout("check_unblockneteasemusic_status();", 5000);
		}
	});
}
function unblock_restart() {
	var dbus_post = {};
	dbus_post["merlinclash_unblockmusic_endpoint"] = db_merlinclash["merlinclash_unblockmusic_endpoint"] = E("merlinclash_unblockmusic_endpoint").value;
	dbus_post["merlinclash_unblockmusic_musicapptype"] = db_merlinclash["merlinclash_unblockmusic_musicapptype"] = E("merlinclash_unblockmusic_musicapptype").value;	
	dbus_post["merlinclash_action"] = db_merlinclash["merlinclash_action"] = "8"

	push_data("clash_config.sh", "toolscript",  dbus_post);	
}
function downloadcert() {
	window.open("http://"+window.location.hostname+"/ext/ca.crt");
}
function geoip_update(action){
	var dbus_post = {};
	var date = new Date();
    var seperator1 = "-";
    var seperator2 = ":";
    var month = date.getMonth() + 1;
    var strDate = date.getDate();
    if (month >= 1 && month <= 9) {
        month = "0" + month;
    }
    if (strDate >= 0 && strDate <= 9) {
        strDate = "0" + strDate;
    }
    var currentdate = date.getFullYear() + seperator1 + month + seperator1 + strDate
            + " " + date.getHours() + seperator2 + date.getMinutes()
            + seperator2 + date.getSeconds();
	require(['/res/layer/layer.js'], function(layer) {
		layer.confirm('<li>你确定要更新GeoIP数据库吗？</li>', {
			shade: 0.8,
		}, function(index) {
			$("#log_content3").attr("rows", "20");
			dbus_post["merlinclash_action"] = db_merlinclash["merlinclash_action"] = action;
			dbus_post["merlinclash_updata_date"] = db_merlinclash["merlinclash_updata_date"] = currentdate;
			push_data("clash_update_ipdb.sh", "start", dbus_post);
			E("geoip_updata_date").innerHTML = "<span style='color: gold'>上次更新时间："+db_merlinclash["merlinclash_updata_date"]+"</span>";
			layer.close(index);
			return true;
		}, function(index) {
			layer.close(index);
			return false;
		});
	});
}
function clash_update(action){
	var dbus_post = {};
	var date = new Date();
    var seperator1 = "-";
    var seperator2 = ":";
    var month = date.getMonth() + 1;
    var strDate = date.getDate();
    if (month >= 1 && month <= 9) {
        month = "0" + month;
    }
    if (strDate >= 0 && strDate <= 9) {
        strDate = "0" + strDate;
    }
    var currentdate = date.getFullYear() + seperator1 + month + seperator1 + strDate
            + " " + date.getHours() + seperator2 + date.getMinutes()
            + seperator2 + date.getSeconds();
	require(['/res/layer/layer.js'], function(layer) {
		layer.confirm('<li>你确定要更新clash二进制吗？</li>', {
			shade: 0.8,
		}, function(index) {
			$("#log_content3").attr("rows", "20");
			dbus_post["merlinclash_action"] = db_merlinclash["merlinclash_action"] = action;
			dbus_post["merlinclash_update_clashdate"] = db_merlinclash["merlinclash_update_clashdate"] = currentdate;
			push_data("clash_update_clashbinary.sh", "restart", dbus_post);
			E("clash_update_date").innerHTML = "<span style='color: gold'>&nbsp;&nbsp;上次更新时间："+db_merlinclash["merlinclash_update_clashdate"]+"</span>";
			layer.close(index);
			return true;
			
		}, function(index) {
			layer.close(index);
			return false;
		});
	});
}
function clash_getversion(action) {
	var dbus_post = {};
	dbus_post["merlinclash_action"] = db_merlinclash["merlinclash_action"] = action;
	push_data("clash_get_binary_history.sh", "start", dbus_post);
}
function clash_replace(action) {
	if(!$.trim($('#merlinclash_clashbinarysel').val())){
		alert("请选择二进制版本");
		return false;
	}
	var dbus_post = {};
	dbus_post["merlinclash_action"] = db_merlinclash["merlinclash_action"] = action;
	dbus_post["merlinclash_clashbinarysel"] = db_merlinclash["merlinclash_clashbinarysel"] = E("merlinclash_clashbinarysel").value;
	push_data("clash_get_binary_history.sh", "restart", dbus_post);
}
function yaml_select(){
	$.ajax({
		url: '/logreaddb.cgi?p=yamls.txt',
		type: 'GET',
		cache:false,
		dataType: 'text',
		success: function(response) {
			//按换行符切割
			var arr = response.split("\n");
			Myselect(arr);
		}
	});
}

var counts;
counts=0;
function Myselect(arr){
	var i;
	counts=arr.length;
	var yamllist = arr;  
	$("#merlinclash_yamlsel").append("<option value=''>--请选择--</option>");
	$("#merlinclash_delyamlsel").append("<option value=''>--请选择--</option>");
	for(i=0;i<yamllist.length-1;i++){
		var a=yamllist[i];
		$("#merlinclash_yamlsel").append("<option value='"+a+"' >"+a+"</option>");
		$("#merlinclash_delyamlsel").append("<option value='"+a+"' >"+a+"</option>");
	}
}
function clashbinary_select(){	
	//var id = parseInt(Math.random() * 100000000);
	//var postData = {"id": id, "method": "clash_getclashbinary.sh", "params":[], "fields": ""};
	$.ajax({
		url: "/logreaddb.cgi?p=clash_binary_history.txt",
		dataType: 'html',
		success: function(response) {
			//if(response.result == id){
				var arr = response.split("\n");
				Myclashbinary(arr);
			//}
		}
	});
}
var binarys;
binarys=0;
function Myclashbinary(arr){
	var k;
	binarys=arr.length;
	var binarylist = arr;  	
	$("#merlinclash_clashbinarysel").append("<option value=''>------------请选择------------</option>");
	for(k=0;k<binarylist.length;k++){
		var a=binarylist[k];
		$("#merlinclash_clashbinarysel").append("<option value='"+a+"' >"+a+"</option>");
	}
}
function proxygroup_select(){
	//var id = parseInt(Math.random() * 100000000);
	//var postData = {"id": id, "method": "clash_getproxygroup.sh", "params":[], "fields": ""};
	$.ajax({
		url: "/logreaddb.cgi?p=proxygroups.txt",
		dataType: 'html',
		success: function(response) {
			//if(response.result == id){
				var arr = response.split("\n");
				Mypgselect(arr);
			//}
		}
	});
}
var pgcounts;
pgcounts=0;
function Mypgselect(arr){
	var i;
	pgcounts=arr.length;
	var pglist = arr;  
	   	$("#merlinclash_pgnodes_proxygroup").append("<option value=''>--请选择--</option>");
	for(i=0;i<pglist.length-1;i++){
		var a=pglist[i];
		$("#merlinclash_pgnodes_proxygroup").append("<option value='"+a+"' >"+a+"</option>");
	}
}
function nproxygroup_select_get(node) {
	$.ajax({
		url: '/logreaddb.cgi?p=proxygroups.txt',
		dataType: 'html',
		success: function(response) {
			//按换行符切割
			var arr = response.split("\n");
			//alert(node);
			nMypgselect(arr,node);
		}
	});
}
function nproxies_select_get(node) {
	$.ajax({
		url: '/logreaddb.cgi?p=proxies.txt',
		dataType: 'html',
		success: function(response) {
			//按换行符切割
			var arr = response.split("\n");
			//alert(node);
			nMypxselect(arr,node);
		}
	});
}
function nMypgselect(arr,node){
	var npgcounts;
	var i;
	npgcounts=arr.length;
	var p = "merlinclash_npgnodes";
	var pgnodes = {};
	var params = ["proxygroup"];
	for (var j = 0; j < params.length; j++) {
		$("#pgnodes_tr_" + node + " input[name='"+ p +"_" + params[j] + "_" + node+ "']").each(function () {
			pgnodes[p + "_" + params[j] + "_" + node] = this.value;
		});
	}
	//alert(pgnodes[p + "_" + params[0] + "_" + node]);
	var b = pgnodes[p + "_" + params[0] + "_" + node];
	var npglist = arr;  
	//$("#merlinclash_pgnodes_proxygroup_" + node).append("<option value=''>--请选择--</option>");

	for(i=0;i<npglist.length-1;i++){
		var a=npglist[i];
		$("#merlinclash_pgnodes_proxygroup_" + node).append("<option value='"+a+"' >"+a+"</option>");
	}
	$("#merlinclash_pgnodes_proxygroup_"+node).find("option[value = '"+b+"']").attr("selected","selected");
}
function nMypxselect(arr,node){
	var npxcounts;
	var i;
	npxcounts=arr.length;
	var p = "merlinclash_npgnodes";
	var pxnodes = {};
	var params = ["nodesel"];
	for (var j = 0; j < params.length; j++) {
		$("#pgnodes_tr_" + node + " input[name='"+ p +"_" + params[j] + "_" + node+ "']").each(function () {
			pxnodes[p + "_" + params[j] + "_" + node] = this.value;
		});
	}
	//alert(pxnodes[p + "_" + params[0] + "_" + node]);
	var c = pxnodes[p + "_" + params[0] + "_" + node];
	var npglist = arr;  
	//$("#merlinclash_pgnodes_nodesel_" + node).append("<option value=''>--请选择--</option>");
	
	for(i=0;i<npglist.length-1;i++){
		var a=npglist[i];
		$("#merlinclash_pgnodes_nodesel_" + node).append("<option value='"+a+"' >"+a+"</option>");	
	}
	$("#merlinclash_pgnodes_nodesel_"+node).find("option[value = '"+c+"']").attr("selected","selected");

}
function proxies_select(){
	//var id = parseInt(Math.random() * 100000000);
	//var postData = {"id": id, "method": "clash_getproxies.sh", "params":[], "fields": ""};
	$.ajax({
		url: "/logreaddb.cgi?p=proxies.txt",
		dataType: 'html',
		success: function(response) {
			//if(response.result == id){
			var arrb = response.split("\n");
			Mypxselect(arrb);
			//}
		}
	});
}
pxcounts=0;
function Mypxselect(arrb){
	var i;
	pxcounts=arrb.length;
	var pxlist = arrb;  
		$("#merlinclash_pgnodes_nodesel").append("<option value=''>--请选择--</option>");
	for(i=0;i<pxlist.length-1;i++){
		var a=pxlist[i];
		$("#merlinclash_pgnodes_nodesel").append("<option value='"+a+"' >"+a+"</option>");
	    }
}
function refresh_acl_table(q) {
	$.ajax({
		type: "GET",
		url: "dbconf?p=merlinclash_acl",
		dataType: "script",
		success: function(data) {
			db_acl = db_merlinclash_acl;
			refresh_acl_html();
			
			//write dynamic table value
			for (var i = 1; i < acl_node_max + 1; i++) {
				$('#merlinclash_acl_type_' + i).val(db_acl["merlinclash_acl_type_" + i]);
				$('#merlinclash_acl_content_' + i).val(db_acl["merlinclash_acl_content_" + i]);
				$('#merlinclash_acl_lianjie_' + i).val(db_acl["merlinclash_acl_lianjie_" + i]);
				
			}
			//after table generated and value filled, set default value for first line_image1
			$('#merlinclash_acl_type').val("SRC-IP-CIDR");
		}
	});
}
function addTr() {
	var acls = {};
	var p = "merlinclash_acl";
	acl_node_max += 1;
	var params = ["type", "content", "lianjie"];
	for (var i = 0; i < params.length; i++) {
		acls[p + "_" + params[i] + "_" + acl_node_max] = $('#' + p + "_" + params[i]).val();
	}
	//var id = parseInt(Math.random() * 100000000);
	//var postData = {"id": id, "method": "dummy_script.sh", "params":[], "fields": acls};
	acls["action_script"] = "dummy_script.sh";
	acls["action_mode"] = "dummy";
	$.ajax({
		type: "POST",
		url: "/applydb.cgi?p=merlinclash_acl",
		data: $.param(acls),
		dataType: "text",
		error: function(xhr) {
			console.log("error in posting config of table");
		},
		success: function(response) {
			refresh_acl_table();
			E("merlinclash_acl_content").value = ""
			E("merlinclash_acl_lianjie").value = ""
		}
	});
	aclid = 0;
}
function delTr(o) {
	var id = $(o).attr("id");
	var ids = id.split("_");
	var p = "merlinclash_acl";
	id = ids[ids.length - 1];
	var acls = {};
	var params = ["type", "content", "lianjie"];
	for (var i = 0; i < params.length; i++) {
		acls[p + "_" + params[i] + "_" + id] = "";
	}
	//var id = parseInt(Math.random() * 100000000);
	//var postData = {"id": id, "method": "dummy_script.sh", "params":[], "fields": acls};
	acls["action_script"] = "dummy_script.sh";
	acls["action_mode"] = "dummy";
	$.ajax({
		type: "POST",
		url: "/applydb.cgi?p=merlinclash_acl",
		data: $.param(acls),
		dataType: "text",
		success: function(response) {			
			refresh_acl_table();
			refreshpage();
		}
	});
}
function refresh_acl_html() {
	acl_confs = getACLConfigs();
	var n = 0;
	for (var i in acl_confs) {
		n++;
	}
	var code = '';
	// acl table th
	code += '<table width="750px" border="0" align="center" cellpadding="4" cellspacing="0" class="FormTable_table acl_lists" style="margin:-1px 0px 0px 0px;">'
	code += '<tr>'
	code += '<th width="25%" style="text-align: center; vertical-align: middle;"><a class="hintstyle" href="javascript:void(0);" onclick="openmcHint(2)">类型</a></th>'
	code += '<th width="25%" style="text-align: center; vertical-align: middle;"><a class="hintstyle" href="javascript:void(0);" onclick="openmcHint(3)">内容</a></th>'
	code += '<th width="25%" style="text-align: center; vertical-align: middle;"><a class="hintstyle" href="javascript:void(0);" onclick="openmcHint(4)">连接方式</a></th>'
	code += '<th width="25%">操作</th>'
	code += '</tr>'
	code += '</table>'
	// acl table input area
	code += '<table id="ACL_table" width="750px" border="0" align="center" cellpadding="4" cellspacing="0" class="list_table acl_lists" style="margin:-1px 0px 0px 0px;">'
		code += '<tr>'
	//类型 
			code += '<td width="25%">'
			code += '<select id="merlinclash_acl_type" style="width:140px;margin:0px 0px 0px 2px;text-align:center;text-align-last:center;padding-left: 12px;" class="input_option">'
			code += '<option value="SRC-IP-CIDR">SRC-IP-CIDR</option>'
			code += '<option value="IP-CIDR">IP-CIDR</option>'
			code += '<option value="DOMAIN-SUFFIX">DOMAIN-SUFFIX</option>'
			code += '<option value="DOMAIN">DOMAIN</option>'
			code += '<option value="DOMAIN-KEYWORD">DOMAIN-KEYWORD</option>'
			code += '<option value="DST-PORT">DST-PORT</option>'
			code += '<option value="SRC-PORT">SRC-PORT</option>'
			code += '<option value="MATCH">MATCH</option>'
			code += '</select>'
			code += '</td>'
	//内容
			code += '<td width="25%">'
			code += '<input type="text" id="merlinclash_acl_content" class="input_ss_table" maxlength="50" style="width:140px;text-align:center" placeholder="" />'
			code += '</td>'
	//连接
			code += '<td width="25%">'
			code += '<input type="text" id="merlinclash_acl_lianjie" class="input_ss_table" maxlength="50" style="width:140px;text-align:center" placeholder="" />'
			code += '</td>'	
	// add/delete 按钮
			code += '<td width="25%">'
			code += '<input style="margin-left: 6px;margin: -2px 0px -4px -2px;" type="button" class="add_btn" onclick="addTr()" value="" />'
			code += '</td>'
		code += '</tr>'
	// acl table rule area
	for (var field in acl_confs) {
		var ac = acl_confs[field];		
		code += '<tr id="acl_tr_' + ac["acl_node"] + '">';
			code += '<td width="25%" id="merlinclash_acl_type_' +ac["acl_node"] + '">' + ac["type"] + '</td>';
			code += '<td width="25%" id="merlinclash_acl_content_' +ac["acl_node"] + '">' + ac["content"] + '</td>';
			code += '<td width="25%" id="merlinclash_acl_lianjie_' +ac["acl_node"] + '">' + ac["lianjie"] + '</td>';			
			
			code += '<td width="25%">';
				code += '<input style="margin: -2px 0px -4px -2px;" id="acl_node_' + ac["acl_node"] + '" class="remove_btn" type="button" onclick="delTr(this);" value="">'
			code += '</td>';
		code += '</tr>';
	}
	code += '</table>';

	$(".acl_lists").remove();
	$('#merlinclash_acl_table').after(code);
	
	//showDropdownClientList('setClientIP', 'ip', 'all', '', 'pull_arrow', 'online');
}
function getACLConfigs() {
	var dict = {};
	acl_node_max = 0;
	for (var field in db_acl) {
		names = field.split("_");
		
		dict[names[names.length - 1]] = 'ok';
	}
	acl_confs = {};
	var p = "merlinclash_acl";
	var params = ["type", "content", "lianjie"];
	for (var field in dict) {
		var obj = {};
		//if (typeof db_acl[p + "_name_" + field] == "undefined") {
		//	obj["name"] = db_acl[p + "_ip_" + field];
		//} else {
		//	obj["name"] = db_acl[p + "_name_" + field];
		//}
		for (var i = 0; i < params.length; i++) {
			var ofield = p + "_" + params[i] + "_" + field;
			if (typeof db_acl[ofield] == "undefined") {
				obj = null;
				break;
			}
			obj[params[i]] = db_acl[ofield];
			
		}
		if (obj != null) {
			var node_a = parseInt(field);
			if (node_a > acl_node_max) {
				acl_node_max = node_a;
			}
			obj["acl_node"] = field;
			acl_confs[field] = obj;
		}
	}
	return acl_confs;
}
function refresh_kcp_table(q) {
	$.ajax({
		type: "GET",
		url: "dbconf?p=merlinclash_kcp",
		dataType: "script",
		success: function(data) {
			db_kcp = db_merlinclash_kcp;
			refresh_kcp_html();
				
			//write dynamic table value
			for (var i = 1; i < kcp_node_max + 1; i++) {
				$('#merlinclash_kcp_lport_' + i).val(db_acl["merlinclash_kcp_lport_" + i]);
				$('#merlinclash_kcp_server_' + i).val(db_acl["merlinclash_kcp_server_" + i]);
				$('#merlinclash_kcp_port_' + i).val(db_acl["merlinclash_kcp_port_" + i]);
				$('#merlinclash_kcp_param_' + i).val(db_acl["merlinclash_kcp_param_" + i]);
			}
			//after table generated and value filled, set default value for first line_image1
		}
	});
}
function addTrkcp() {
	var kcps = {};
	var p = "merlinclash_kcp";
	kcp_node_max += 1;
	var params = ["lport", "server", "port", "param"];
	for (var i = 0; i < params.length; i++) {
		kcps[p + "_" + params[i] + "_" + kcp_node_max] = $('#' + p + "_" + params[i]).val();
		
	}
	//var id = parseInt(Math.random() * 100000000);
	//var postData = {"id": id, "method": "dummy_script.sh", "params":[], "fields": kcps};
	kcps["action_script"] = "dummy_script.sh";
	kcps["action_mode"] = "dummy";
	$.ajax({
		type: "POST",
		url: "/applydb.cgi?p=merlinclash_kcp",
		data: $.param(kcps),
		dataType: "text",
		error: function(xhr) {
			console.log("error in posting config of table");
		},
		success: function(response) {
			refresh_kcp_table();
			E("merlinclash_kcp_lport").value = ""
			E("merlinclash_kcp_server").value = ""
			E("merlinclash_kcp_port").value = ""
			E("merlinclash_kcp_param").value = ""
		}
	});
	kcpid = 0;
}
function saveTrkcp(o) {
	var id = $(o).attr("id"); //kcp_nodes_1
	var ids = id.split("_");
	var p = "merlinclash_kcp";
	id = ids[ids.length - 1];
	var kcps = {};
	var params = ["lport", "server", "port", "param"];


	for (var i = 0; i < params.length; i++) {
		$("#kcp_tr_" + id + " input[name='"+ p +"_" + params[i] + "_" + id+ "']").each(function () {
			kcps[p + "_" + params[i] + "_" + id] = this.value;
		});
	}
	//var id = parseInt(Math.random() * 100000000);
	//var postData = {"id": id, "method": "dummy_script.sh", "params":[], "fields": kcps};
	kcps["action_script"] = "dummy_script.sh";
	kcps["action_mode"] = "dummy";
	$.ajax({
		type: "POST",
		url: "/applydb.cgi?p=merlinclash_kcp",
		data: $.param(kcps),
		dataType: "text",
		success: function(response) {		
			refresh_kcp_table();
			refreshpage();
		}
	});	
}
function delTrkcp(o) {
	var id = $(o).attr("id");
	var ids = id.split("_");
	var p = "merlinclash_kcp";
	id = ids[ids.length - 1];
	var kcps = {};
	var params = ["lport", "server", "port", "param"];
	for (var i = 0; i < params.length; i++) {
		kcps[p + "_" + params[i] + "_" + id] = "";
	}
	//var id = parseInt(Math.random() * 100000000);
	//var postData = {"id": id, "method": "dummy_script.sh", "params":[], "fields": kcps};
	kcps["action_script"] = "dummy_script.sh";
	kcps["action_mode"] = "dummy";
	$.ajax({
		type: "POST",
		url: "/applydb.cgi?p=merlinclash_kcp",
		data: $.param(kcps),
		dataType: "text",
		success: function(response) {		           
			refresh_kcp_table();
			refreshpage();
		}
	});
}
function refresh_kcp_html() {
	kcp_confs = getkcpConfigs();
	var n = 0;
	for (var i in kcp_confs) {
		n++;
	}
	var code2 = '';
	// kcp table th
	code2 += '<table width="750px" border="0" align="center" cellpadding="4" cellspacing="0" class="FormTable_table kcp_lists" style="margin:-1px 0px 0px 0px;">'
		code2 += '<tr>'
			code2 += '<th width="10%" style="text-align: center; vertical-align: middle;">监听端口</th>'
			code2 += '<th width="20%" style="text-align: center; vertical-align: middle;">kcp服务器</th>'
			code2 += '<th width="10%" style="text-align: center; vertical-align: middle;">kcp端口</th>'
			code2 += '<th width="40%" style="text-align: center; vertical-align: middle;">kcp参数</th>'
			code2 += '<th width="20%">操作</th>'
		code2 += '</tr>'
	code2 += '</table>'
	// kcp table input area
	code2 += '<table id="KCP_table" width="750px" border="0" align="center" cellpadding="4" cellspacing="0" class="list_table kcp_lists" style="margin:-1px 0px 0px 0px;">'
		code2 += '<tr>'
	//监听端口
			code2 += '<td width="10%">'
				code2 += '<input type="text" id="merlinclash_kcp_lport" class="input_ss_table" maxlength="6" style="width:80%;text-align:center;" placeholder="" />'
			code2 += '</td>'
	//KCP服务器 
			code2 += '<td width="20%">'
				code2 += '<input type="text" id="merlinclash_kcp_server" class="input_ss_table" maxlength="20" style="width:90%;text-align:center;" placeholder="" />'
			code2 += '</td>'
	//端口
			code2 += '<td width="10%">'
				code2 += '<input type="text" id="merlinclash_kcp_port" class="input_ss_table" maxlength="6" style="width:80%;text-align:center;" placeholder="" />'
			code2 += '</td>'
	//参数
			code2 += '<td width="40%">'
				code2 += '<input type="text" id="merlinclash_kcp_param" class="input_ss_table" maxlength="5000" style="width:90%;text-align:center;" placeholder="" />'
				code2 += '</td>'	
	// add/delete 按钮
			code2 += '<td width="20%">'
				code2 += '<input style="margin-left: 6px;margin: -2px 0px -4px -2px;" type="button" class="add_btn" onclick="addTrkcp()" value="" />'
			code2 += '</td>'
		code2 += '</tr>'
	// kcp table data area
	for (var field in kcp_confs) {
		var kc = kcp_confs[field];		
		code2 += '<tr id="kcp_tr_' + kc["kcp_node"] + '">';
			code2 += '<td width="10%">'
				code2 += '<input type="text" id="merlinclash_kcp_lport_' + kc["kcp_node"] +' "name="merlinclash_kcp_lport_' + kc["kcp_node"] +'" class="input_option_2" maxlength="6" style="width:80%;text-align:center;" value="' + kc["lport"] +'" />'
			code2 += '</td>';
			code2 += '<td width="20%">'
				code2 += '<input type="text" id="merlinclash_kcp_server_' + kc["kcp_node"] +' "name="merlinclash_kcp_server_' + kc["kcp_node"] +'" class="input_option_2" maxlength="20" style="width:90%;text-align:center;" value="' + kc["server"] +'" />'
			code2 += '</td>';
			code2 += '<td width="10%">'
				code2 += '<input type="text" id="merlinclash_kcp_port_' + kc["kcp_node"] +' "name="merlinclash_kcp_port_' + kc["kcp_node"] +'" class="input_option_2" maxlength="6" style="width:80%;text-align:center;" value="' + kc["port"] +'" />'
			code2 += '</td>';
			code2 += '<td width="40%">'
				code2 += '<input type="text" id="merlinclash_kcp_param_' + kc["kcp_node"] +' "name="merlinclash_kcp_param_' + kc["kcp_node"] +'" class="input_option_2" maxlength="5000" style="width:90%;text-align:center;" value="' + kc["param"] +'" />'
				code2 += '</td>';
			code2 += '<td width="20%">';
				code2 += '<input style="margin: 0px 0px -4px -2px;" id="kcp_nodes_' + kc["kcp_node"] + '" class="edit_btn" type="button" onclick="saveTrkcp(this);" value="">'
				code2 += ' '
				code2 += '<input style="margin: 0px 0px -4px -2px;" id="kcp_noded_' + kc["kcp_node"] + '" class="remove_btn" type="button" onclick="delTrkcp(this);" value="">'
				//code2 += '<input style="width:60px" id="kcp_nodes_' + kc["kcp_node"] + '" class="ss_btn" type="button" onclick="saveTrkcp(this);" value="保存">'
				//code2 += ' '
				//code2 += '<input style="width:60px" id="kcp_noded_' + kc["kcp_node"] + '" class="ss_btn" type="button" onclick="delTrkcp(this);" value="删除">'
			code2 += '</td>';
		code2 += '</tr>';
	}
	code2 += '</table>';

	$(".kcp_lists").remove();
	$('#merlinclash_kcp_table').after(code2);
	
}
function getkcpConfigs() {
	var dictkcp = {};
	kcp_node_max = 0;
	for (var field in db_kcp) {
		kcpnames = field.split("_");
		
		dictkcp[kcpnames[kcpnames.length - 1]] = 'ok';
	}
	kcp_confs = {};
	var p = "merlinclash_kcp";
	var params = ["lport", "server", "port", "param"];
	for (var field in dictkcp) {
		var obj = {};
		for (var i = 0; i < params.length; i++) {
			var ofield = p + "_" + params[i] + "_" + field;
			if (typeof db_kcp[ofield] == "undefined") {
				obj = null;
				break;
			}
			obj[params[i]] = db_kcp[ofield];
			
		}
		if (obj != null) {
			var node_a = parseInt(field);
			if (node_a > kcp_node_max) {
				kcp_node_max = node_a;
			}
			obj["kcp_node"] = field;
			kcp_confs[field] = obj;
		}
	}
	return kcp_confs;
}
function getpgnodesmax(){
	$.ajax({
		type: "GET",
		url: "dbconf?p=merlinclash_pgnodes",
		dataType: "script",
		success: function(data) {
			db_pgnodes = db_merlinclash_pgnodes;
			getpgnodesConfigs();
			//after table generated and value filled, set default value for first line_image1
		}
	});
}
function refresh_pgnodes_table(q) {
	$.ajax({
		type: "GET",
		url: "dbconf?p=merlinclash_pgnodes",
		dataType: "script",
		success: function(data) {
			db_pgnodes = db_merlinclash_pgnodes;
			refresh_pgnodes_html();
				
			//write dynamic table value
			for (var i = 1; i < pgnodes_node_max + 1; i++) {
				$('#merlinclash_pgnodes_proxygroup_' + i).val(db_acl["merlinclash_pgnodes_proxygroup_" + i]);
				$('#merlinclash_pgnodes_nodesel_' + i).val(db_acl["merlinclash_pgnodes_nodesel_" + i]);

			}
			//after table generated and value filled, set default value for first line_image1
		}
	});
}
function addTrpgnodes() {
	if(!$.trim($('#merlinclash_pgnodes_proxygroup').val())){
		alert("Proxy-Group不能为空！");
		return false;
	}
	if(!$.trim($('#merlinclash_pgnodes_nodesel').val())){
		alert("节点不能为空！");
		return false;
	}
	var pgnodes = {};
	var p = "merlinclash_pgnodes";
	pgnodes_node_max += 1;
	var params = ["proxygroup", "nodesel"];
	for (var i = 0; i < params.length; i++) {
		pgnodes[p + "_" + params[i] + "_" + pgnodes_node_max] = $('#' + p + "_" + params[i]).val();
		
	}
	//var id = parseInt(Math.random() * 100000000);
	//var postData = {"id": id, "method": "dummy_script.sh", "params":[], "fields": pgnodes};
	pgnodes["action_script"] = "dummy_script.sh";
	pgnodes["action_mode"] = "dummy";
	$.ajax({
		type: "POST",
		url: "/applydb.cgi?p=merlinclash_pgnodes",
		data: $.param(pgnodes),
		dataType: "text",
		error: function(xhr) {
			console.log("error in posting config of table");
		},
		success: function(response) {
			refresh_pgnodes_table();
			E("merlinclash_pgnodes_proxygroup").value = "";
			E("merlinclash_pgnodes_nodesel").value = "";
			proxygroup_select();
			proxies_select();
		}
	});
	pgnodespid = 0;
}
function saveTrpgnodes(o) {
	var id = $(o).attr("id"); 
	var ids = id.split("_");
	var p = "merlinclash_npgnodes";
	var q = "merlinclash_pgnodes";
	id = ids[ids.length - 1];
	var pgnodes = {};
	var params = ["proxygroup", "nodesel"];


	for (var i = 0; i < params.length; i++) {
		$("#pgnodes_tr_" + id + " input[name='"+ p +"_" + params[i] + "_" + id+ "']").each(function () {
			pgnodes[q + "_" + params[i] + "_" + id] = $("#merlinclash_pgnodes_"+ params[i] + "_" +id).val();
		//	alert($("#merlinclash_pgnodes_"+ params[i] + "_" +id).val());
		//	alert(pgnodes[q + "_" + params[i] + "_" + id]);
		});
	}
	//alert(pgnodes[q + "_" + params[1] + "_" + id]);
	//var id = parseInt(Math.random() * 100000000);
	//var postData = {"id": id, "method": "dummy_script.sh", "params":[], "fields": pgnodes};
	pgnodes["action_script"] = "dummy_script.sh";
	pgnodes["action_mode"] = "dummy";
	$.ajax({
		type: "POST",
		url: "/applydb.cgi?p=merlinclash_pgnodes",
		data: $.param(pgnodes),
		dataType: "text",
		success: function(response) {		
			refresh_pgnodes_table();
			refreshpage();
		}
	});	
}
function delTrpgnodes(o) {
	var id = $(o).attr("id");
	var ids = id.split("_");
	var p = "merlinclash_pgnodes";
	id = ids[ids.length - 1];
	var pgnodes = {};
	var params = ["proxygroup", "nodesel"];
	for (var i = 0; i < params.length; i++) {
		pgnodes[p + "_" + params[i] + "_" + id] = "";
	}
	//var id = parseInt(Math.random() * 100000000);
	//var postData = {"id": id, "method": "dummy_script.sh", "params":[], "fields": pgnodes};
	pgnodes["action_script"] = "dummy_script.sh";
	pgnodes["action_mode"] = "dummy";
	$.ajax({
		type: "POST",
		url: "/applydb.cgi?p=merlinclash_pgnodes",
		data: $.param(pgnodes),
		dataType: "text",
		success: function(response) {		           
			refresh_pgnodes_table();
			refreshpage();
		}
	});
}
function delallpgnodes() {
		getpgnodesmax();
		if(pgnodes_node_max != "undefined"){
			var p = "merlinclash_pgnodes";
			pgnodes_node_del = pgnodes_node_max;
			var pgnodes = {};
			var params = ["proxygroup", "nodesel"];
			for (var j=pgnodes_node_del; j>0; j--) {
				for (var i = 0; i < params.length; i++) {
					pgnodes[p + "_" + params[i] + "_" + j] = "";		
				}
			}
			pgnodes_node_max = 0;
			//var id = parseInt(Math.random() * 100000000);
			//var postData = {"id": id, "method": "dummy_script.sh", "params":[], "fields": pgnodes};

	pgnodes["action_script"] = "dummy_script.sh";
	pgnodes["action_mode"] = "dummy";
	$.ajax({
		type: "POST",
		url: "/applydb.cgi?p=merlinclash_pgnodes",
		data: $.param(pgnodes),
		dataType: "text",
				success: function(response) {		           
					refresh_pgnodes_table();
					refreshpage();
				}
			});	
		}
			
}
function apply_delallpgnodes() {
		getpgnodesmax();
		if(pgnodes_node_max != null){
			var p = "merlinclash_pgnodes";
			pgnodes_node_del = pgnodes_node_max;
			//alert(pgnodes_node_del);
			var pgnodes = {};
			var params = ["proxygroup", "nodesel"];
			for (var j=pgnodes_node_del; j>0; j--) {
				for (var i = 0; i < params.length; i++) {
					db_merlinclash["merlinclash_pgnodes_" + params[i] + "_" + j] = pgnodes["merlinclash_pgnodes_" + params[i] + "_" + j] = "";
					db_merlinclash["merlinclash_npgnodes_" + params[i] + "_" + j] = pgnodes["merlinclash_npgnodes_" + params[i] + "_" + j] = "";
					//alert("a"+pgnodes[p + "_" + params[i] + "_" + j]);		
				}
			}
			pgnodes_node_max = 0;
			var id = parseInt(Math.random() * 100000000);
			var postData = {"id": id, "method": "dummy_script.sh", "params":[], "fields": pgnodes};
	pgnodes["action_script"] = "dummy_script.sh";
	pgnodes["action_mode"] = "dummy";
	$.ajax({
		type: "POST",
		url: "/applydb.cgi?p=merlinclash_pgnodes",
		data: $.param(pgnodes),
		dataType: "text",
				success: function(response) {
					//alert("b"+pgnodes["merlinclash_pgnodes_proxygroup_1"]);
					//alert("c"+pgnodes["merlinclash_npgnodes_proxygroup_1"]);
					refresh_pgnodes_table();
					//alert('检测到配置文件变化，将清空前配置节点指定内容');
				}
			});	
		}
			
}
function refresh_pgnodes_html() {
	pgnodes_confs = getpgnodesConfigs();
	var code2 = '';
	//table th
	code2 += '<table width="750px" border="0" align="center" cellpadding="4" cellspacing="0" class="FormTable_table pgnodes_lists" style="margin:-1px 0px 0px 0px;">'
		code2 += '<tr>'
			code2 += '<th width="40%" style="text-align: center; vertical-align: middle;">Proxy-Group</th>'
			code2 += '<th width="40%" style="text-align: center; vertical-align: middle;">节点</th>'
			code2 += '<th width="20%">操作</th>'
		code2 += '</tr>'
	code2 += '</table>'
	// table input area
	code2 += '<table id="PGNODES_table" width="750px" border="0" align="center" cellpadding="4" cellspacing="0" class="list_table pgnodes_lists" style="margin:-1px 0px 0px 0px;">'
		code2 += '<tr>'
	//Proxy-Group
			code2 += '<td width="40%">'
				code2 += '<select id="merlinclash_pgnodes_proxygroup" style="width:140px;margin:0px 0px 0px 2px;text-align:center;text-align-last:center;padding-left: 12px;" class="input_option">'
				code2 += '</select>'
			code2 += '</td>'
	//节点
			code2 += '<td width="40%">'
				code2 += '<select id="merlinclash_pgnodes_nodesel" style="width:140px;margin:0px 0px 0px 2px;text-align:center;text-align-last:center;padding-left: 12px;" class="input_option">'
				code2 += '</select>'
			code2 += '</td>'	
	// add/delete 按钮
			code2 += '<td width="20%">'
				code2 += '<input style="margin-left: 6px;margin: -2px 0px -4px -2px;" type="button" class="add_btn" onclick="addTrpgnodes()" value="" />'
			code2 += '</td>'
		code2 += '</tr>'
	// kcp table data area
	for (var field in pgnodes_confs) {
		var pc = pgnodes_confs[field];		
		code2 += '<tr id="pgnodes_tr_' + pc["pgnodes_node"] + '">';
			code2 += '<td width="40%">'
				code2 += '<input type="hidden" id="merlinclash_npgnodes_proxygroup_' + pc["pgnodes_node"] +' " name="merlinclash_npgnodes_proxygroup_' + pc["pgnodes_node"] +'" class="input_option_2" maxlength="6" style="width:80%;text-align:center;" value="' + pc["proxygroup"] +'" />'
				code2 += '<select id="merlinclash_pgnodes_proxygroup_'+ pc["pgnodes_node"] + '" name="merlinclash_pgnodes_proxygroup_' + pc["pgnodes_node"] +'" style="width:140px;margin:0px 0px 0px 2px;text-align:center;text-align-last:center;padding-left: 12px;" class="input_option">'
				code2 += '</select>'
			code2 += '</td>';
			code2 += '<td width="40%">'
				code2 += '<input type="hidden" id="merlinclash_npgnodes_nodesel_' + pc["pgnodes_node"] +' " name="merlinclash_npgnodes_nodesel_' + pc["pgnodes_node"] +'" class="input_option_2" maxlength="20" style="width:90%;text-align:center;" value="' + pc["nodesel"] +'" />'
				code2 += '<select id="merlinclash_pgnodes_nodesel_'+ pc["pgnodes_node"] + '" name="merlinclash_pgnodes_nodesel_' + pc["pgnodes_node"] +'" style="width:140px;margin:0px 0px 0px 2px;text-align:center;text-align-last:center;padding-left: 12px;" class="input_option">'
				code2 += '</select>'
			code2 += '</td>';
			code2 += '<td width="20%">';
				code2 += '<input style="margin: 0px 0px -4px -2px;" id="pgnodes_nodes_' + pc["pgnodes_node"] + '" class="edit_btn" type="button" onclick="saveTrpgnodes(this);" value="">'
				code2 += ' '
				code2 += '<input style="margin: 0px 0px -4px -2px;" id="pgnodes_noded_' + pc["pgnodes_node"] + '" class="remove_btn" type="button" onclick="delTrpgnodes(this);" value="">'
				//code2 += '<input style="width:60px" id="pgnodes_nodes_' + pc["pgnodes_node"] + '" class="ss_btn" type="button" onclick="saveTrpgnodes(this);" value="保存">'
				//code2 += ' '
				//code2 += '<input style="width:60px" id="pgnodes_noded_' + pc["pgnodes_node"] + '" class="ss_btn" type="button" onclick="delTrpgnodes(this);" value="删除">'
			code2 += '</td>';
		code2 += '</tr>';
		nproxygroup_select_get(pc["pgnodes_node"]);
		nproxies_select_get(pc["pgnodes_node"]);
	}
	code2 += '</table>';

	$(".pgnodes_lists").remove();
	$('#merlinclash_pgnodes_table').after(code2);

}
function getpgnodesConfigs() {
	var dictpgnodes = {};
	pgnodes_node_max = 0;
	for (var field in db_pgnodes) {
		pgnodesnames = field.split("_");
		
		dictpgnodes[pgnodesnames[pgnodesnames.length - 1]] = 'ok';
	}
	pgnodes_confs = {};
	var p = "merlinclash_pgnodes";
	var params = ["proxygroup", "nodesel"];
	for (var field in dictpgnodes) {
		var obj = {};
		for (var i = 0; i < params.length; i++) {
			var ofield = p + "_" + params[i] + "_" + field;
			if (typeof db_pgnodes[ofield] == "undefined") {
				obj = null;
				break;
			}
			obj[params[i]] = db_pgnodes[ofield];
			
		}
		if (obj != null) {
			var node_a = parseInt(field);
			if (node_a > pgnodes_node_max) {
				pgnodes_node_max = node_a;
			}
			obj["pgnodes_node"] = field;
			pgnodes_confs[field] = obj;
		}
	}
	return pgnodes_confs;
}
</script>
<script>
	// IP 检查
	var IP = {
		get: (url, type) =>
			fetch(url, { method: 'GET' }).then((resp) => {
				if (type === 'text')
					return Promise.all([resp.ok, resp.status, resp.text(), resp.headers]);
				else {
					return Promise.all([resp.ok, resp.status, resp.json(), resp.headers]);
				}
			}).then(([ok, status, data, headers]) => {
				if (ok) {
					let json = {
						ok,
						status,
						data,
						headers
					}
					return json;
				} else {
					throw new Error(JSON.stringify(json.error));
				}
			}).catch(error => {
				throw error;
			}),
		parseIPIpip: (ip, elID) => {
			IP.get(`https://api.skk.moe/network/parseIp/ipip/v3/${ip}`, 'json')
				.then(resp => {
					let x = '';
					for (let i of resp.data) {
						x += (i !== '') ? `${i} ` : '';
					}
	
					E(elID).innerHTML = x;
					//E(elID).innerHTML = `${resp.data.country} ${resp.data.regionName} ${resp.data.city} ${resp.data.isp}`;
				})
		},
		getIpipnetIP: () => {
			IP.get(`https://myip.ipip.net?${+(new Date)}`, 'text')
				.then(resp => E('ip-ipipnet').innerHTML = resp.data.replace('当前 IP：', '').replace('来自于：', ''));
		},
		getSohuIP: (data) => {
			E('ip-sohu').innerHTML = returnCitySN.cip;
			IP.parseIPIpip(returnCitySN.cip, 'ip-sohu-ipip');
		},
		getIpsbIP: (data) => {
			E('ip-ipsb').innerHTML = data.address;
			E('ip-ipsb-geo').innerHTML = `${data.country} ${data.province} ${data.city} ${data.isp.name}`
		},
		getIpApiIP: () => {
			IP.get(`https://api.ipify.org/?format=json&id=${+(new Date)}`, 'json')
				.then(resp => {
					E('ip-ipapi').innerHTML = resp.data.ip;
					return resp.data.ip;
				})
				.then(ip => {
					IP.parseIPIpip(ip, 'ip-ipapi-geo');
				})
		},
	};
	// 网站访问检查
	var HTTP = {
		checker: (domain, cbElID) => {
			let img = new Image;
			let timeout = setTimeout(() => {
				img.onerror = img.onload = null;
				img = null;
				E(cbElID).innerHTML = '<span style="color:#F00">连接超时</span>'
			}, 5000);
	
			img.onerror = () => {
				clearTimeout(timeout);
				E(cbElID).innerHTML = '<span style="color:#F00">无法访问</span>'
			}
	
			img.onload = () => {
				clearTimeout(timeout);
				E(cbElID).innerHTML = '<span style="color:#6C0">连接正常</span>'
			}
	
			img.src = `https://${domain}/favicon.ico?${+(new Date)}`
		},
		runcheck: () => {
			HTTP.checker('www.baidu.com', 'http-baidu');
			//HTTP.checker('s1.music.126.net/style', 'http-163');
			HTTP.checker('github.com', 'http-github');
			HTTP.checker('www.youtube.com', 'http-youtube');
		}
	};
	var merlinclash = {
		checkIP: () => {	
			IP.getIpipnetIP();
			//IP.getSohuIP();
			IP.getIpApiIP();
			HTTP.runcheck();
			setTimeout("merlinclash.checkIP();", 10000);
		},
	}
function menu_hook(title, tab) {
	tabtitle[tabtitle.length -1] = new Array("", "软件中心", "离线安装", "Merlin Clash");
	tablink[tablink.length -1] = new Array("", "Main_Soft_center.asp", "Main_Soft_setting.asp", "Module_merlinclash.asp");
}
</script>
</head>
<body onload="init();">
<div id="TopBanner"></div>
<div id="Loading" class="popup_bg"></div>
<div id="LoadingBar" class="popup_bar_bg_ks" style="z-index: 200;" >
<table cellpadding="5" cellspacing="0" id="loadingBarBlock" class="loadingBarBlock" align="center">
	<tr>
		<td height="100">
		<div id="loading_block3" style="margin:10px auto;margin-left:10px;width:85%; font-size:12pt;"></div>
		<div id="loading_block2" style="margin:10px auto;width:95%;"></div>
		<div id="log_content2" style="margin-left:15px;margin-right:15px;margin-top:10px;overflow:hidden">
			<textarea cols="50" rows="36" wrap="off" readonly="readonly" id="log_content3" autocomplete="off" autocorrect="off" autocapitalize="off" spellcheck="false" style="border:1px solid #000;width:99%; font-family:'Lucida Console'; font-size:11px;background:transparent;color:#FFFFFF;outline: none;padding-left:3px;padding-right:22px;overflow-x:hidden"></textarea>
		</div>
		<div id="ok_button" class="apply_gen" style="background: #000;display: none;">
			<input id="ok_button1" class="button_gen" type="button" onclick="hideMCLoadingBar()" value="确定">
		</div>
		</td>
	</tr>
</table>
</div>
<table class="content" align="center" cellpadding="0" cellspacing="0">
	<tr>
		<td width="17">&nbsp;</td>
		<td valign="top" width="202">
			<div id="mainMenu"></div>
			<div id="subMenu"></div>
		</td>
		<td valign="top">
			<div id="tabMenu" class="submenuBlock"></div>
			<table width="98%" border="0" align="left" cellpadding="0" cellspacing="0" style="display: block;">
				<tr>
					<td align="left" valign="top">
						<div>
							<table width="760px" border="0" cellpadding="5" cellspacing="0" bordercolor="#6b8fa3" class="FormTitle" id="FormTitle">
								<tr>
									<td bgcolor="#4D595D" colspan="3" valign="top">
										<div>&nbsp;</div>
										<div class="formfonttitle">Merlin Clash</div>
										<div style="float:right; width:15px; height:25px;margin-top:-20px">
											<img id="return_btn" onclick="reload_Soft_Center();" align="right" style="cursor:pointer;position:absolute;margin-left:-30px;margin-top:-25px;" title="返回软件中心" src="/images/backprev.png" onMouseOver="this.src='/images/backprevclick.png'" onMouseOut="this.src='/images/backprev.png'"></img>
										</div>
										<div style="margin:10px 0 10px 5px;" class="splitLine"></div>
										<div class="SimpleNote" id="head_illustrate"><i></i>
											<p><a href="https://github.com/Dreamacro/clash" target="_blank"><em><u>Clash</u></em></a>是一个基于规则的代理程序，本插件使用<a href="https://github.com/BROBIRD/clash/releases" target="_blank"><em><u>BROBIRD</u></em></a>编译的ClashR内核，支持<a href="https://github.com/shadowsocks/shadowsocks-libev" target="_blank"><em><u>SS</u></em></a>、<a href="https://github.com/shadowsocksrr/shadowsocksr-libev" target="_blank"><em><u>SSR</u></em></a>、<a href="https://github.com/v2ray/v2ray-core" target="_blank"><em><u>V2Ray</u></em></a>、<a href="https://github.com/trojan-gfw/trojan" target="_blank"><em><u>Trojan</u></em></a>等方式科学上网。</p>
											<p style="color:#FC0">注意：1.Clash需要专用订阅或配置文件才可以使用，如果您的机场没提供订阅，可以使用插件内置的2种【<a style="cursor:pointer" onclick="dingyue()" href="javascript:void(0);"><em><u>规则转换</u></em></a>】，</p>
											<p style="color:#FC0">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;或者使用【<a href="https://acl4ssr.netlify.app/" target="_blank"><em><u>ACL4SSR 在线订阅转换</u></em></a>】。
											<p style="color:#FC0">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;2.本插件不能与【<a href="./Module_shadowsocks.asp" target="_blank"><em><u>科学上网</u></em></a>】同时运行。开启后如果Aria2/AiCloud无法外网访问，请设置<a href="./Advanced_VirtualServer_Content.asp" target="_blank"><em><u>端口转发</u></em></a>。</p>
											<p style="color:#FC0">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;3.使用延迟最低(Url-Test)&nbsp;|&nbsp;故障切换(Fallback)&nbsp;|&nbsp;负载均衡(Load-Balance)等自动策略组前，请确认您的机场允许频繁TCPing，</p>
											<p style="color:#FC0">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;否则您的帐号可能会被限制。</p>
										</div>
										<!-- this is the popup area for process status -->
										<div id="detail_status"  class="content_status" style="box-shadow: 3px 3px 10px #000;margin-top: -20px;display: none;">
											<div class="user_title">【Merlin Clash】状态检测</div>
											<div style="margin-left:15px"><i>&nbsp;&nbsp;目前本功能支持Merlin Clash相关进程状态和iptables表状态检测。</i></div>
											<div style="margin: 10px 10px 10px 10px;width:98%;text-align:center;overflow:hidden">
												<textarea cols="63" rows="36" wrap="off" id="proc_status" style="width:98%;padding-left:13px;padding-right:33px;border:0px solid #222;font-family:'Lucida Console'; font-size:11px;background: transparent;color:#FFFFFF;outline: none;overflow-x:hidden;" autocomplete="off" autocorrect="off" autocapitalize="off" spellcheck="false"></textarea>
											</div>
											<div style="margin-top:5px;padding-bottom:10px;width:100%;text-align:center;">
												<input class="button_gen" type="button" onclick="close_proc_status();" value="返回主界面">
											</div>
										</div>
										<!-- this is the popup area for foreign status -->
										<div id="merlinclash_switch_show" style="margin:-1px 0px 0px 0px;">
											<table style="margin:-1px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" id="merlinclash_switch_table">
												<thead>
												<tr>
													<td colspan="2">开关</td>
												</tr>
												</thead>
												<tr>
												<th id="merlinclash_switch">Merlin Clash开关</th>
													<td colspan="2">
														<div class="switch_field" style="display:table-cell;float: left;">
															<label for="merlinclash_enable">
																<input id="merlinclash_enable" class="switch" type="checkbox" style="display: none;">
																<div class="switch_container" >
																	<div class="switch_bar"></div>
																	<div class="switch_circle transition_style">
																		<div></div>
																	</div>
																</div>
															</label>
														</div>
														<div id="merlinclash_version_show" style="display:table-cell;float: left;position: absolute;margin-left:70px;padding: 5.5px 0px;">
															<a class="hintstyle">
																<i>当前版本：</i>
															</a>
														</div>
														<div style="display:table-cell;float: left;margin-left:200px;position: absolute;padding: 5.5px 0px;">
															<a type="button" class="ss_btn" style="cursor:pointer" onclick="get_proc_status()" href="javascript:void(0);">详细状态</a>
														</div>
													</td>
												</tr>
											</table>
										</div>
										<div id="tablets">
											<table style="margin:10px 0px 0px 0px;border-collapse:collapse" width="100%" height="37px">
												<tr>
													<td cellpadding="0" cellspacing="0" style="padding:0" border="1" bordercolor="#222">
														<input id="show_btn0" class="show-btn0" width="11%" style="cursor:pointer" type="button" value="首页功能" />
														<input id="show_btn1" class="show-btn1" width="11%" style="cursor:pointer" type="button" value="配置文件" />
														<input id="show_btn7" class="show-btn7" width="11%" style="cursor:pointer" type="button" value="节点指定" />
														<input id="show_btn2" class="show-btn2" width="11%" style="cursor:pointer" type="button" value="自定规则" />
														<input id="show_btn3" class="show-btn3" width="11%" style="cursor:pointer" type="button" value="高级模式" />
                                                        <input id="show_btn8" class="show-btn8" width="11%" style="cursor:pointer" type="button" value="云村解锁" />
														<input id="show_btn4" class="show-btn4" width="11%" style="cursor:pointer" type="button" value="附加功能" />
														<input id="show_btn5" class="show-btn5" width="11%" style="cursor:pointer" type="button" value="操作日志" />
														<input id="show_btn6" class="show-btn6" width="11%" style="cursor:pointer" type="button" value="当前配置" />
													</td>
												</tr>
											</table>
										</div>
										<div id="tablet_0" style="display: none;">
											<div id="merlinclash-content-overview">												
												<table style="margin:-1px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" >
													<thead>
														<tr>
															<td colspan="2">状态检查</td>
														</tr>
														</thead>
													<tr id="clash_state">
														<th>插件运行状态</th>
															<td>
																<div style="display:table-cell;float: left;margin-left:0px;">
																	
																		<span id="clash_state2">Clash 进程状态 - Waiting...</span>
																		<br/>
																		<span id="clash_state3">Clash 看门狗进程状态 - Waiting...</span>
																	
																</div>
															</td>
														</tr>
												</table>
												<div id="merlinclash-ip" style="margin:-1px 0px 0px 0px;">
												<table style="margin:-1px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" >																							
													<tr id="ip_state">
														<th>连通性检查</th>
															<td>
																<div style="padding-right: 20px;">
																	<div style="display: flex;">
																		<div style="width: 61.8%">IP 地址检查</div>
																		<div style="width: 40%">网站访问检查</div>
																	</div>
																</div>
																<div>
																	<div style="display: flex;">
																		<div style="width: 61.8%">
																			<p><span class="ip-title">IPIP&nbsp;&nbsp;国内</span>:&nbsp;<span id="ip-ipipnet"></span></p>
																			<p><span class="ip-title">IPAPI&nbsp;海外</span>:&nbsp;<span id="ip-ipapi"></span>&nbsp;<span id="ip-ipapi-geo"></span></p>
																		</div>
																		<div style="width: 40%">
																			<p><span class="ip-title">百度搜索</span>&nbsp;:&nbsp;<span id="http-baidu"></span></p>
																			<p><span class="ip-title">GitHub</span>&nbsp;:&nbsp;<span id="http-github"></span></p>
																			<p><span class="ip-title">YouTube</span>&nbsp;:&nbsp;<span id="http-youtube"></span></p>
																		</div>
																	</div>
																	<p><span style="float: right">（只检测您浏览器当前状况）</p>
																	<p><span style="float: right">Powered by <a href="https://ip.skk.moe" target="_blank">ip.skk.moe</a></span></p>
																</div>
															</td>
													</tr>
												</table>
												</div>
													<div id="merlinclash-yamls" style="margin:-1px 0px 0px 0px;">
														<form name="form1">
														<table style="margin:-1px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" >																							
															<thead>
																<tr>
																	<td colspan="2">配置文件</td>
																</tr>
																</thead>
															<tr id="yamlselect">
																<th>配置文件选择</th>
																	<td colspan="2">
																		<!--<input type="hidden" value="${stu.merlinclash_yamlsel}" id="yamlfile" />-->
																		<select id="merlinclash_yamlsel"  name="yamlsel" dataType="Notnull" msg="配置文件不能为空!"></select>
																	</td>
															</tr>
														</table>
														</form>
													</div>
												<div id="merlinclash-dns" style="margin:-1px 0px 0px 0px;">
													<table style="margin:-1px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" >																							
														<thead>
															<tr>
																<td colspan="2">DNS方案</td>
															</tr>
															</thead>
														<tr id="dns_plan">
															<th><a class="hintstyle" href="javascript:void(0);" onclick="openmcHint(1)">DNS方案</a></th>
																<td colspan="2">
																	<label for="merlinclash_dnsplan">
																		<input id="merlinclash_dnsplan" type="radio" name="dnsplan" value="de" checked="checked">默认:按上传配置文件DNS方案
																		<input id="merlinclash_dnsplan" type="radio" name="dnsplan" value="rh">Redir-Host
																		<input id="merlinclash_dnsplan" type="radio" name="dnsplan" value="rhp">Redir-Host+
																		<input id="merlinclash_dnsplan" type="radio" name="dnsplan" value="fi">Fake-ip
																	</label>
																	<p style="color:#FC0">&nbsp;</p>
																	<p style="color:#FC0">&nbsp;注意：1.如果您没有足够的自信，请不要使用默认DNS方案。</p>
																	<p style="color:#FC0">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;2.Reidr-Host，国内解析优先，但DNS可能被污染。</p>
																	<p style="color:#FC0">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;3.Reidr-Host+，解析速度可能较慢，DNS基本无污染。</p>
																	<p style="color:#FC0">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;4.Fake-ip，拒绝DNS污染，无法通过ping获得真实IP。<a href="https://github.com/Fndroid/clash_for_windows_pkg/wiki/DNS%E6%B1%A1%E6%9F%93%E5%AF%B9Clash%EF%BC%88for-Windows%EF%BC%89%E7%9A%84%E5%BD%B1%E5%93%8D" target="_blank"><em><u>相关说明</u></em></a></p>
																	<p style="color:#FC0">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(Fake-ip模式暂不兼容KoolProxy，切忌在此模式下升级路由固件)。</p>
																</td>
														</tr>
													</table>
												</div>
												<table style="margin:-1px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" id="merlinclash_switch_table">
														<thead>
														<tr>
															<td colspan="2">Clash面板</td>
														</tr>
														</thead>
														<tr id="clash_dashboard">
															<th>面板信息</th>
																<td>
																	<div style="display:table-cell;float: left;margin-left:0px;">																			
																		<span id="dashboard_state2">面板host</span> <span id="dashboard_state3">面板端口</span>
																	</div>
																</td>
															</tr>
														<tr>
														<th id="btn-open-clash-dashboard" class="btn btn-primary">访问 Clash 面板</th>
															<td colspan="2">
																<div class="merlinclash-btn-container">
																	<!--<a href="http://yacd.haishan.me/" target="_blank" id="yacd" ><button type="button" class="ss-btn">访问 YACD-Clash 面板</button></a>
																	<a href="http://clash.razord.top/" target="_blank" id="yacd" ><button type="button" class="ss-btn">访问 RAZORD-Clash 面板</button></a>-->
																	<a type="button" style="vertical-align: middle; cursor:pointer;" id="yacd" class="ss_btn" href="http://yacd.haishan.me/" target="_blank" >访问 YACD-Clash 面板</a>
																	<a type="button" style="vertical-align: middle; cursor:pointer;" class="ss_btn" id="razord" href="http://clash.razord.top/" target="_blank">访问 RAZORD-Clash 面板</a>
																	
																	<p style="margin-top: 8px">只有在 Clash 正在运行的时候才可以访问 Clash 面板</p>
																</div>
															</td>
														</tr>
														<tr>
															<th id="btn-quicklyrestart" class="btn btn-primary">快速重启</th>
																<td colspan="2">
																	<div class="merlinclash-btn-quicklyrestart">																	
																		<a type="button" style="vertical-align: middle; cursor:pointer;" class="ss_btn" id="quicklyrestart" onclick="quickly_restart()">&nbsp;&nbsp;快速重启&nbsp;&nbsp;</a><a class="hintstyle" href="javascript:void(0);" onclick="openmcHint(7)"><em style="color: gold;">【功能说明】</em></a>														
																	</div>
																</td>
															</tr>
												</table>
											</div>
										</div>
										<div id="tablet_1" style="display: none;">
											<div id="merlinclash-content-config" style="margin:-1px 0px 0px 0px;">
												<table style="margin:-1px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" id="merlinclash_switch_table">
													<thead>
													<tr>
														<td colspan="2">导入Clash配置文件</td>
													</tr>
													</thead>
													<tr>
													<th id="btn-open-clash-dashboard" class="btn btn-primary">手动上传Clash配置文件 <p style="color: red;">文件名必须为字母/数字！</p></th>
													<td colspan="2">
														<div class="SimpleNote" style="display:table-cell;float: left; height: 110px; line-height: 110px; margin:-40px 0;">
															<input type="file" id="clashconfig" size="50" name="file"/>
															<span id="clashconfig_info" style="display:none;">完成</span>															
															<a type="button" style="vertical-align: middle; cursor:pointer;" id="clashconfig-btn-upload" class="ss_btn" onclick="upload_clashconfig()" >上传配置文件</a>
														</div>
													</td>
													</tr>
													<tr>
														<th><br>在线Clash订阅
															<br>
															<br><em style="color: gold;">Clash专用订阅&nbsp;|&nbsp;ACL4SSR等转换订阅</em>
														</th>
														<td >
															<div class="SimpleNote" style="display:table-cell;float: left;">
																<label for="merlinclash_links">
																	<textarea id="merlinclash_links" placeholder="&nbsp;&nbsp;&nbsp;请输入订阅连接（只支持单个订阅地址）" type="text" style="color: #FFFFFF; height:100px; width:400px;background-color:rgba(87,109,115,0.5); font-family: Arial, Helvetica, sans-serif; font-weight:normal; font-size:12px;"></textarea>
																</label>
															</div>
															<div class="SimpleNote" style="display:table-cell;float: left; height: 110px; line-height: 110px; margin:-40px 0;">
																<input onkeyup="value=value.replace(/[^\w\.\/]/ig,'')" id="merlinclash_uploadrename" maxlength="8" style="color: #FFFFFF; width: 300px; height: 20px; background-color:rgba(87,109,115,0.5); font-family: Arial, Helvetica, sans-serif; font-weight:normal; font-size:12px;margin:-30px 0;" placeholder="&nbsp;重命名,支持8位数字/字母">
																<a type="button" style="vertical-align: middle; margin:-10px 10px;" class="ss_btn" style="cursor:pointer" onclick="get_online_yaml(2)" href="javascript:void(0);">&nbsp;&nbsp;Clash订阅&nbsp;&nbsp;</a>
																</div>
														</td>
													</tr>
												</table>
												<table style="margin:-1px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" id="merlinclash_switch_table">

													
													<thead>
													<tr>
														<td colspan="2">其他订阅转换Clash规则&nbsp;&nbsp;&nbsp;&nbsp;<a class="hintstyle" href="javascript:void(0);" onclick="openmcHint(6)"><em>【帮助】</em></td>
													</tr>
													</thead>
													<tr>
														<th><br>常规订阅
															<br>
															<br><em style="color: gold;">SS&nbsp;|&nbsp;SSR&nbsp;|&nbsp;V2ray&nbsp;|&nbsp;Trojan订阅</em>			
															<br><em style="color: gold;">（使用内置8k+规则，杜绝订阅泄漏）</em>
															<br><em style="color: red;">节点数过百后可能处理速度缓慢</em>
														</th>
														<td >
															<div class="SimpleNote" style="display:table-cell;float: left;">
																<label for="merlinclash_links2">
																	<textarea id="merlinclash_links2" placeholder="&nbsp;&nbsp;&nbsp;请输入订阅连接（只支持单个订阅地址）" type="text" style="color: #FFFFFF; height:100px; width:400px;background-color:rgba(87,109,115,0.5); font-family: Arial, Helvetica, sans-serif; font-weight:normal; font-size:12px;"></textarea>
																</label>
															</div>
															<div class="SimpleNote" style="display:table-cell;float: left; height: 110px; line-height: 110px; margin:-40px 0;">
																<input onkeyup="value=value.replace(/[^\w\.\/]/ig,'')" id="merlinclash_uploadrename2" maxlength="8" style="color: #FFFFFF; width: 300px; height: 20px; background-color:rgba(87,109,115,0.5); font-family: Arial, Helvetica, sans-serif; font-weight:normal; font-size:12px;margin:-30px 0;" placeholder="&nbsp;重命名,支持8位数字/字母">
																<a type="button" style="vertical-align: middle; margin:-10px 10px;" class="ss_btn" style="cursor:pointer" onclick="get_online_yaml2(2)" href="javascript:void(0);">&nbsp;&nbsp;开始转换&nbsp;&nbsp;</a>
															</div>
														</td>
													</tr>
													<tr>
														<th><br>通过ACL4SSR在线转换
															<br>
															<br><em style="color: gold;">SS&nbsp;|&nbsp;SSR&nbsp;|&nbsp;V2ray订阅</em>
															<br><em style="color: gold;">规则与GitHub项目同步更新</em>	
															<br><em style="color: gold;">规则默认选项并非最优，还需自己摸索</em>																
														</th>
														<td >
															<div class="SimpleNote" style="display:table-cell;float: left;">
																<label for="merlinclash_links3">
																	<textarea id="merlinclash_links3" placeholder="&nbsp;&nbsp;&nbsp;请输入订阅连接（只支持单个订阅地址）" type="text" style="color: #FFFFFF; height:100px; width:400px;background-color:rgba(87,109,115,0.5); font-family: Arial, Helvetica, sans-serif; font-weight:normal; font-size:12px;"></textarea>
																</label>
															</div>														
															<div class="SimpleNote" style="display:table-cell;float: left; height: 110px; line-height: 110px; margin:-40px 0;">
																<select id="merlinclash_acl4ssrsel" style="width:140px;margin:0px 0px 0px 2px;text-align:left;padding-left: 0px;" class="input_option">
																	<option value="Online">Online默认版_分组比较全</option>
																	<option value="AdblockPlus">AdblockPlus_更多去广告</option>	
																	<option value="NoAuto">NoAuto_无自动测速</option>	
																	<option value="NoReject">NoReject_无广告拦截规则</option>	
																	<option value="Mini">Mini_精简版</option>	
																	<option value="Mini_AdblockPlus">Mini_AdblockPlus_精简版更多去广告</option>	
																	<option value="Mini_NoAuto">Mini_NoAuto_精简版无自动测速</option>
																	<option value="Mini_Fallback">Mini_Fallback_精简版带故障转移</option>	
																	<option value="Mini_MultiMode">Mini_MultiMode_精简版自动测速故障转移负载均衡</option>																				
																</select>
																<input onkeyup="value=value.replace(/[^\w\.\/]/ig,'')" id="merlinclash_uploadrename4" maxlength="5" style="color: #FFFFFF; width: 150px; height: 20px; background-color:rgba(87,109,115,0.5); font-family: Arial, Helvetica, sans-serif; font-weight:normal; font-size:12px;margin:-30px 0;" placeholder="&nbsp;重命名,支持5位数字/字母">
																<a type="button" style="vertical-align: middle; margin:-10px 10px;" class="ss_btn" style="cursor:pointer" onclick="get_online_yaml3(2)" href="javascript:void(0);">&nbsp;&nbsp;开始转换&nbsp;&nbsp;</a>
															</div>
														</td>
													</tr>
												</table>
												<table style="margin:-1px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" >																							
													<thead>
														<tr>
															<td colspan="2">导入【<a href=" ./Module_shadowsocks.asp" target="_blank"><em style="color:gold;">科学上网</em></a> 】节点</td>
														</tr>
														</thead>
													<tr id="ssconvert">
														<th>读取科学上网节点，转换为Clash规则</th>
															<td colspan="2">
																<div class="SimpleNote" style="display:table-cell;float: left; height: 110px; line-height: 110px; margin:-40px 0;">
																<input onkeyup="value=value.replace(/[^\w\.\/]/ig,'')" id="merlinclash_uploadrename3" maxlength="8" style="color: #FFFFFF; width: 180px; height: 20px; background-color:rgba(87,109,115,0.5); font-family: Arial, Helvetica, sans-serif; font-weight:normal; font-size:12px;margin:-30px 0;" placeholder="&nbsp;转换文件命名,支持8位数字/字母">
																<label for="merlinclash_ssconvert_btn">
																	<a type="button" style="vertical-align: middle; margin:-10px 10px;" class="ss_btn" style="cursor:pointer" onclick="ssconvert(6)" href="javascript:void(0);">&nbsp;&nbsp;一键转换&nbsp;&nbsp;</a>																
																</label>
															</div>
															</td>
													</tr>
												</table>
												<form name="form1">
													<table style="margin:-1px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" >																							
														<thead>
															<tr>
																<td colspan="2">下载&nbsp;|&nbsp;删除配置文件</td>
															</tr>
															</thead>
														<tr id="delyamlselect">
															<th>配置文件选择</th>
															<td colspan="2">
																<div class="SimpleNote" style="display:table-cell;float: left; height: 110px; line-height: 110px; margin:-40px 0;">
																<!--<input type="hidden" value="${stu.merlinclash_yamlsel}" id="yamlfile" />-->
																<select id="merlinclash_delyamlsel"  name="delyamlsel" dataType="Notnull" msg="配置文件不能为空!"></select>
																<a type="button" style="vertical-align: middle;" class="ss_btn" style="cursor:pointer" onclick="download_yaml_sel()" href="javascript:void(0);">下载</a>
																<a type="button" style="vertical-align: middle;" class="ss_btn" style="cursor:pointer" onclick="del_yaml_sel(0)" href="javascript:void(0);" >删除</a>
															</div>
															</td>
														</tr>
													</table>
													</form>
											</div>				
										</div>
										<!--节点指定-->
										<div id="tablet_7" style="display: none;">
											<div id="merlinclash_pgnodes_table">
											</div>												
											<div id="MEMO_note" style="margin:10px 0 0 5px">
											<div><i>&nbsp;&nbsp;1.该功能可以设定Clash初始策略组配置，仅对当前配置文件有效</i></div>
											<div><i>&nbsp;&nbsp;2.如果您的设置不符合Clash的标准，进程会无法启动。请删除所有配置，重新尝试。</i></div>
											<div><i>&nbsp;</i></div>
											</div>				
										</div>
										<!--自定规则-->
										<div id="tablet_2" style="display: none;">
																							
											<div id="merlinclash_acl_table">
											</div>												
											<div id="ACL_note" style="margin:10px 0 0 5px">
											<div><i>&nbsp;&nbsp;1.编辑规则有风险，请勿在没完全搞懂的情况下，胡乱尝试。</i></div>
											<div><i>&nbsp;&nbsp;2.如果您添加的规则不符合Clash的标准，进程会无法启动。请删除所有自定义规则，重新启动。</i></div>
											<div><i>&nbsp;&nbsp;3.如果新加规则和老规则冲突，则会按照新规则执行。</i></div>
											<div><i>&nbsp;&nbsp;4.【访问控制】写法示例：</i></div>
											<div><i>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;让某设备不过代理：类型：<em>SRC-IP-CIDR</em>，内容：<em>192.168.50.201/32</em>（IP必须有掩码位），连接方式：<em>DIRECT</em>（大写）</i></div>
											<div><i>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;禁止某端口联网：类型：<em>DST-PORT</em>，内容：<em>7777</em>（端口号），连接方式：<em>REJECT</em>（大写）</i></div>
											<div><i>&nbsp;&nbsp;5.更多说明请点击表头查看，或者参阅Clash的【<a href="https://lancellc.gitbook.io/clash/clash-config-file/rules" target="_blank"><em><u>开发文档</u></em></a>】。</i></div>
											<div><i>&nbsp;</i></div>
										</div>
										</div>
										<!--高级模式-->
										<div id="tablet_3" style="display: none;">
											<div id="merlinclash-ipv6" style="margin:-1px 0px 0px 0px;">
												<table style="margin:-1px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" >																							
													<thead>
														<tr>
															<td colspan="2">IPv6解析服务 -- 默认关闭</td>
														</tr>
														</thead>
													<tr id="dns_ipv6">
														<th>开启IPv6 DNS解析</th>
															<td colspan="2">
																<label for="merlinclash_ipv6switch">
																	<input id="merlinclash_ipv6switch" type="checkbox" name="ipv6" >
																</label>
															</td>
													</tr>
												</table>
											</div>
											<!--
											<div id="merlinclash-neteasemusic" style="margin:-1px 0px 0px 0px;">
												<table style="margin:-1px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" >																							
													<thead>
														<tr>
															<td colspan="2">网易云音乐解锁 --服务器解锁 <a href='https://github.com/DesperadoJ/Rules-for-UnblockNeteaseMusic' target="_blank"><em style="color: gold;">【感谢DesperadoJ提供的解锁服务器】</em></a></td>
														</tr>
														</thead>
													<tr id="neteasemusic">
														<th>开启网易云音乐解锁</th>
															<td colspan="2">
																<label for="merlinclash_nmswitch">
																	<input id="merlinclash_nmswitch" type="checkbox" name="unblockneteasemusic" >
																</label>
															</td>
													</tr>
												</table>
											</div>
											
											<div id="merlinclash-koolproxy" style="margin:-1px 0px 0px 0px;">
												<table style="margin:-1px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" >																							
													<thead>
														<tr>
															<td colspan="2">兼容koolproxy --【仅限FAKE-IP模式】</td>
														</tr>
														</thead>
													<tr id="koolproxy">
														<th>开启koolproxy兼容</th>
															<td colspan="2">
																<label for="merlinclash_kpswitch">
																	<input id="merlinclash_kpswitch" type="checkbox" name="koolproxy_compatible;" >
																</label>
															</td>
													</tr>
												</table>
											</div>
											-->
											<div id="merlinclash-content-config" style="margin:-1px 0px 0px 0px;">
												<table style="margin:-1px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" id="merlinclash_switch_table">
													<thead>
													<tr>
														<td colspan="2">KCP加速 -- 需要服务器端支持  <a class="hintstyle" href="javascript:void(0);" onclick="openmcHint(5)"><em>【帮助】</em></a> <a class="hintstyle" href="https://github.com/xtaci/kcptun/releases" target="_blank"><em style="color:gold;">【二进制下载】</em></a> </td>
													</tr>
													</thead>
													<tr>
														<th>KCP开关</th>
															<td colspan="2">
																<div class="switch_field" style="display:table-cell;float: left;">
																	<label for="merlinclash_kcpswitch">
																		<input id="merlinclash_kcpswitch" class="switch" type="checkbox" style="display: none;">
																		<div class="switch_container" >
																			<div class="switch_bar"></div>
																			<div class="switch_circle transition_style">
																				<div></div>
																			</div>
																		</div>
																	</label>
																</div>																	
															</td>
														</tr>
												</table>
												<div id="merlinclash_kcp_table">
												</div>
											</div>	
											
										</div>
										<!--网易云解锁-->
										<div id="tablet_8" style="display: none;">
											<div id="merlinclash-unblockneteasemusic" style="margin:-1px 0px 0px 0px;">
												<table style="margin:-1px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" >																							
													<thead>
														<tr>
															<td colspan="2">设置</td>
														</tr>
														</thead>
														<tr>
															<th >本地解锁开关</th>
															<td colspan="2">
																<div class="switch_field" style="display:table-cell;float: left;">
																	<label for="merlinclash_unblockmusic_enable">
																		<input id="merlinclash_unblockmusic_enable" class="switch" type="checkbox" style="display: none;">
																		<div class="switch_container">
																			<div class="switch_bar"></div>
																			<div class="switch_circle transition_style">
																				<div></div>
																			</div>
																		</div>
																	</label>
																</div>
															</td>
														</tr>
														<tr>
															<th >插件版本</th>
															<td colspan="2"  id="merlinclash_unblockmusic_version">
															</td>
														</tr>
														<tr>
															<th >状态</th>
															<td colspan="2"  id="merlinclash_unblockmusic_status">
															</td>
														</tr>
														<tr id="merlinclash_unblockmusic_musicapptype_tr">
															<th>
																<label >音源</label>
															</th>
															<td>
																<div style="float:left; width:165px; height:25px">
																	<select id="merlinclash_unblockmusic_musicapptype" name="merlinclash_unblockmusic_musicapptype" style="width:164px;margin:0px 0px 0px 2px;" class="input_option">
																		<option value="default" >Default</option>
																		<option value="netease" >Netease</option>
																		<option value="qq" >QQ</option>
																		<option value="xiami" >Xiami</option>
																		<option value="baidu" >Baidu</option>
																		<option value="kugou" >Kugou</option>
																		<option value="kuwo" >Kuwo</option>
																		<option value="migu" >Migu</option>
																		<option value="joox" >Joox</option>
																	</select>
																</div>
															</td>
														</tr>
														<tr id="merlinclash_unblockmusic_endpoint_tr">
															<th>
																<label >Endpoint</label>
															</th>
															<td>
																<input type="text" id="merlinclash_unblockmusic_endpoint" name="merlinclash_unblockmusic_endpoint" class="input_ss_table" style="width:200px;" value="https://music.163.com" />
															</td>
														</tr>
														<tr id="merlinclash_unblockmusic_bestquality_tr">
															<th>
																<label >强制音质优先</label>
															</th>
															<td>
																<label for="merlinclash_unblockmusic_bestquality">
																	<input id="merlinclash_unblockmusic_bestquality" type="checkbox" name="unblockmusic_bestquality">
																</label>
															</td>
														</tr>
														<tr id="cert_download_tr">
															<th>
																<label >证书下载</label>&nbsp;&nbsp;<a class="hintstyle" href="javascript:void(0);" onclick="openmcHint(8)"><em style="color: gold;">【IOS说明】</em></a>																
															</th>
															<td>
																<input  type="button" id="merlinclash_unblockmusic_download_cert" class="button_gen" onclick="downloadcert();" value="下载证书" />
																
															</td>
														</tr>
														<tr id="unblockneteasemusic_restart_tr">
															<th>
																<label >重启进程</label>
															</th>
															<td>
																<input  type="button" id="merlinclash_unblockmusic_restart" class="button_gen" onclick="unblock_restart();" value="重启解锁进程" />
															</td>
														</tr>
												</table>
												<div id="UBM_note" style="margin:10px 0 0 5px"><i></i><em style="color: gold;">&nbsp;&nbsp;&nbsp;需要先安装网易云解锁插件，可实现解锁音乐变灰歌曲，并通过Clash规则精准分流。<br>1.开启后，通过Clash分流功能自动实现解锁，无需手动设置代理。<br>2.可通过Clash的<a href="http://yacd.haishan.me" target="_blank"><em>【管理面板】</em></a>，打开或者关闭解锁功能。<br>3.相对于之前解锁方式，本地解锁更加安全快速。<br>4.苹果设备如果无法正常解锁，请设置 WIFI/有线代理方式为<em>【自动】</em> ,并安装 <em>【CA根证书】</em>并<em>【信任】</em>。<br>5.如果通过Clash分流解锁失败，可以尝试在APP里设置如下代理：<br>&nbsp;&nbsp;&nbsp;HTTP代理IP:<% nvram_get("lan_ipaddr"); %>，端口:5200<br>&nbsp;&nbsp;&nbsp;HTTPS代理IP:<% nvram_get("lan_ipaddr"); %>，端口:5300</div>
												
											</div>	
										</div>
										<!--附加功能-->
										<div id="tablet_4" style="display: none;">
											<div id="merlinclash-content-additional" style="margin:-1px 0px 0px 0px;">
												<table style="margin:-1px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" id="merlinclash_switch_table">
													<thead>
													<tr>
														<td colspan="2">Clash 看门狗</td>
													</tr>
													</thead>
													<tr>
													<th>Clash 看门狗开关</th>
														<td colspan="2">
															<div class="switch_field" style="display:table-cell;float: left;">
																<label for="merlinclash_watchdog">
																	<input id="merlinclash_watchdog" class="switch" type="checkbox" style="display: none;">
																	<div class="switch_container" >
																		<div class="switch_bar"></div>
																		<div class="switch_circle transition_style">
																			<div></div>
																		</div>
																	</div>
																</label>
															</div>
															<div class="SimpleNote" id="head_illustrate">
																<p>MerlinClash 实现的 Clash 进程守护工具，每 60 秒检查一次 Clash 进程是否存在，如果 Clash 进程丢失则会自动重新拉起。</p>
																<p style="color:gold; margin-top: 8px">注意：Clash本身运行稳定，通常不必开启该功能~且由于Clash不支持保存节点选择状态，进程重新启后策略组配置会恢复初始状态！</p>
															</div>
														</td>
													</tr>
												</table>
												<table style="margin:-1px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" id="merlinclash_switch_table">
													<thead>
													<tr>
														<td colspan="2">更新管理</td>
													</tr>
													</thead>
													<tr>
													<th>GeoIP 数据库</th>
														<td colspan="2">
															<div class="SimpleNote" id="head_illustrate">
																<p>Clash 使用由 <a href="https://www.maxmind.com/" target="_blank"><u>MaxMind</u></a> 提供的 <a href="https://dev.maxmind.com/geoip/geoip2/geolite2/" target="_blank"><u>GeoLite2</u></a> IP 数据库解析 GeoIP 规则</p>
																<p style="color:#FC0">注：更新不会对比新旧版本号，重复点击会重复升级！（1个月左右更新一次即可）</p>
																<p>&nbsp;</p>
																<a type="button" class="ss_btn" style="cursor:pointer" onclick="geoip_update(5)">更新GeoIP数据库</a>
																<span id="geoip_updata_date">上次更新时间：</span>
																<!--<a type="button" class="ss_btn" style="cursor:pointer" href="https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-Country&license_key=oeEqpP5QI21N&suffix=tar.gz">点击下载GeoIP数据库</a>-->
															</div>
														</td>		
													</tr>
													<!--
													<tr>
														<th>clash二进制更新</th>
															<td colspan="2">
																<div class="SimpleNote" id="head_illustrate">																	
																	<a type="button" class="ss_btn" style="cursor:pointer" onclick="clash_update(7)">更新clash二进制</a>
																	<span id="clash_update_date">&nbsp;&nbsp;上次更新时间：</span>
																</div>
															</td>		
													</tr>
													-->
													<tr>
														<th>clash二进制替换 --在线更换</th>
															<td colspan="2">
																<div class="SimpleNote" id="head_illustrate">
																	<select id="merlinclash_clashbinarysel"  name="clashbinarysel" dataType="Notnull"></select>
																	<a type="button" class="ss_btn" style="cursor:pointer" onclick="clash_getversion(10)">获取远程版本文件</a>		
																	<a type="button" class="ss_btn" style="cursor:pointer" onclick="clash_replace(11)">替换clash二进制</a>																	
																</div>
															</td>		
													</tr>
													<tr>
														<th>clash二进制替换 --本地替换</th>
															<td colspan="2">
																<div class="SimpleNote" style="display:table-cell;float: left; height: 110px; line-height: 110px; margin:-40px 0;">
																	<input type="file" id="clashbinary" size="50" name="file"/>
																	<span id="clashbinary_upload" style="display:none;">完成</span>															
																	<a type="button" style="vertical-align: middle; cursor:pointer;" id="clashbinary-btn-upload" class="ss_btn" onclick="upload_clashbinary()" >上传clash二进制</a>
																</div>
															</td>		
													</tr>
												</table>												
												<table style="margin:-1px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" id="merlinclash_dnsfiles_table">
													<thead>
													<tr>
														<td colspan="2">内置DNS方案 -- <em style="color: gold;">【不懂勿动，编辑完成点击“提交修改”保存配置，下次启动Merlin Clash时生效】</em></td>
													</tr>
													</thead>
													<tr>
													<th>【Redir-Host】&nbsp;&nbsp;&nbsp;&nbsp;<a style="color: gold;">-nameserver:</a></th>
														<td colspan="2">
															<div class="SimpleNote" id="head_illustrate">
																<input id="merlinclash_rh_nameserver1" style="color: #FFFFFF; width: 300px; height: 20px; background-color:rgba(87,109,115,0.5); font-family: Arial, Helvetica, sans-serif; font-weight:normal; font-size:12px;" placeholder="">																
																<br>
																<br>
																<input id="merlinclash_rh_nameserver2" style="color: #FFFFFF; width: 300px; height: 20px; background-color:rgba(87,109,115,0.5); font-family: Arial, Helvetica, sans-serif; font-weight:normal; font-size:12px;" placeholder="">																
																<br>
																<br>
																<input id="merlinclash_rh_nameserver3" style="color: #FFFFFF; width: 300px; height: 20px; background-color:rgba(87,109,115,0.5); font-family: Arial, Helvetica, sans-serif; font-weight:normal; font-size:12px;" placeholder="">																
															</div>
														</td>		
													</tr>
													<tr>
														<th>【Redir-Host】&nbsp;&nbsp;&nbsp;&nbsp;<a style="color: gold;">-fallback:</a></th>
															<td colspan="2">
																<div class="SimpleNote" id="head_illustrate">
																	<input id="merlinclash_rh_fallback1" style="color: #FFFFFF; width: 300px; height: 20px; background-color:rgba(87,109,115,0.5); font-family: Arial, Helvetica, sans-serif; font-weight:normal; font-size:12px;" placeholder="">																
																	<br>
																	<br>
																	<input id="merlinclash_rh_fallback2" style="color: #FFFFFF; width: 300px; height: 20px; background-color:rgba(87,109,115,0.5); font-family: Arial, Helvetica, sans-serif; font-weight:normal; font-size:12px;" placeholder="">																
																	<br>
																	<br>
																	<input id="merlinclash_rh_fallback3" style="color: #FFFFFF; width: 300px; height: 20px; background-color:rgba(87,109,115,0.5); font-family: Arial, Helvetica, sans-serif; font-weight:normal; font-size:12px;" placeholder="">																
																														
																</div>
															</td>		
													</tr>
													<tr>
														<th>【Redir-Host+】&nbsp;&nbsp;&nbsp;&nbsp;<a style="color: gold;">-nameserver:</a></th>
															<td colspan="2">
																<div class="SimpleNote" id="head_illustrate">
																	<input id="merlinclash_rhp_nameserver1" style="color: #FFFFFF; width: 300px; height: 20px; background-color:rgba(87,109,115,0.5); font-family: Arial, Helvetica, sans-serif; font-weight:normal; font-size:12px;" placeholder="">																
																	<br>
																	<br>
																	<input id="merlinclash_rhp_nameserver2" style="color: #FFFFFF; width: 300px; height: 20px; background-color:rgba(87,109,115,0.5); font-family: Arial, Helvetica, sans-serif; font-weight:normal; font-size:12px;" placeholder="">																
																	<br>
																	<br>
																	<input id="merlinclash_rhp_nameserver3" style="color: #FFFFFF; width: 300px; height: 20px; background-color:rgba(87,109,115,0.5); font-family: Arial, Helvetica, sans-serif; font-weight:normal; font-size:12px;" placeholder="">																
															</div>
															</td>		
														</tr>
														<tr>
															<th>【Redir-Host+】&nbsp;&nbsp;&nbsp;&nbsp;<a style="color: gold;">-fallback:</a></th>
																<td colspan="2">
																	<div class="SimpleNote" id="head_illustrate">
																		<input id="merlinclash_rhp_fallback1" style="color: #FFFFFF; width: 300px; height: 20px; background-color:rgba(87,109,115,0.5); font-family: Arial, Helvetica, sans-serif; font-weight:normal; font-size:12px;" placeholder="">																
																		<br>
																		<br>
																		<input id="merlinclash_rhp_fallback2" style="color: #FFFFFF; width: 300px; height: 20px; background-color:rgba(87,109,115,0.5); font-family: Arial, Helvetica, sans-serif; font-weight:normal; font-size:12px;" placeholder="">																
																		<br>
																		<br>
																		<input id="merlinclash_rhp_fallback3" style="color: #FFFFFF; width: 300px; height: 20px; background-color:rgba(87,109,115,0.5); font-family: Arial, Helvetica, sans-serif; font-weight:normal; font-size:12px;" placeholder="">																
																																
																	</div>
																</td>		
														</tr>
														<tr>
															<th>【Fake-ip】&nbsp;&nbsp;&nbsp;&nbsp;<a style="color: gold;">-nameserver:</a></th>
																<td colspan="2">
																	<div class="SimpleNote" id="head_illustrate">
																		<input id="merlinclash_fi_nameserver1" style="color: #FFFFFF; width: 300px; height: 20px; background-color:rgba(87,109,115,0.5); font-family: Arial, Helvetica, sans-serif; font-weight:normal; font-size:12px;" placeholder="">																
																		<br>
																		<br>
																		<input id="merlinclash_fi_nameserver2" style="color: #FFFFFF; width: 300px; height: 20px; background-color:rgba(87,109,115,0.5); font-family: Arial, Helvetica, sans-serif; font-weight:normal; font-size:12px;" placeholder="">																
																		<br>
																		<br>
																		<input id="merlinclash_fi_nameserver3" style="color: #FFFFFF; width: 300px; height: 20px; background-color:rgba(87,109,115,0.5); font-family: Arial, Helvetica, sans-serif; font-weight:normal; font-size:12px;" placeholder="">																
																														
																	</div>
																</td>		
															</tr>
															<tr>
																<th>【Fake-ip】&nbsp;&nbsp;&nbsp;&nbsp;<a style="color: gold;">-fallback:</a></th>
																	<td colspan="2">
																		<div class="SimpleNote" id="head_illustrate">
																			<input id="merlinclash_fi_fallback1" style="color: #FFFFFF; width: 300px; height: 20px; background-color:rgba(87,109,115,0.5); font-family: Arial, Helvetica, sans-serif; font-weight:normal; font-size:12px;" placeholder="">																
																			<br>
																			<br>
																			<input id="merlinclash_fi_fallback2" style="color: #FFFFFF; width: 300px; height: 20px; background-color:rgba(87,109,115,0.5); font-family: Arial, Helvetica, sans-serif; font-weight:normal; font-size:12px;" placeholder="">																
																			<br>
																			<br>
																			<input id="merlinclash_fi_fallback3" style="color: #FFFFFF; width: 300px; height: 20px; background-color:rgba(87,109,115,0.5); font-family: Arial, Helvetica, sans-serif; font-weight:normal; font-size:12px;" placeholder="">																
																																				
																		</div>
																	</td>		
															</tr>
														<tr>
															<th></th>															
															<td colspan="2">
																		<div class="SimpleNote" id="head_illustrate">
																			<a type="button" style="margin: 100px; vertical-align: middle; cursor:pointer"  class="ss_btn" onclick="dnsfilechange()">&nbsp;&nbsp;修改提交&nbsp;&nbsp;</a>																
																		</div>
																	</td>		
														</tr>
												</table>
											</div>
										</div>
											<div id="tablet_5" style="display: none;">
											<div id="log_content" style="margin-top:-1px;overflow:hidden;">
												<textarea cols="63" rows="36" wrap="on" readonly="readonly" id="log_content1" autocomplete="off" autocorrect="off" autocapitalize="off" spellcheck="false"></textarea>
											</div>
										</div>
										<div id="tablet_6" style="display: none;">
											<div id="yaml_content" style="margin-top:-1px;overflow:hidden;">
												<textarea cols="63" rows="36" wrap="on" readonly="readonly" id="yaml_content1" autocomplete="off" autocorrect="off" autocapitalize="off" spellcheck="false"></textarea>
											</div>
										</div>
										<div class="apply_gen" id="loading_icon">
											<img id="loadingIcon" style="display:none;" src="/images/InternetScan.gif">
										</div>
										<div id="delallpgnodes_button" class="apply_gen">
											<input class="button_gen" type="button" onclick="delallpgnodes()" value="全部删除">	
										</div>
										<div id="apply_button" class="apply_gen">
											<input class="button_gen" type="button" onclick="apply()" value="保存&应用">
										</div>
									</td>
								</tr>
							</table>
						</div>
					</td>
				</tr>
			</table>
		</td>
		<td width="10" align="center" valign="top"></td>
	</tr>
</table>
<div id="footer"></div>
</body>
</html>

