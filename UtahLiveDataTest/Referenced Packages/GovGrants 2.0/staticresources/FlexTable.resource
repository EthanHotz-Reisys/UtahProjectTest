var namespace = flexTable_namespace;


						  
function adjustToggleBarHeightUI(){
	var finalHeight = 0;
	var paddingtop = 0;
	var paddingtop1 = 0;
	var windowHeight = j$(window).height();
	var loginpanelHeight = j$('#loginpanel').height();
	var rightpanelHeight = j$('#rightPanel').height();
	var rightColumnHeight = j$('#rightcolumn').height();
	//finalHeight =  rightColumnHeight;
	finalHeight = Math.max( windowHeight, rightColumnHeight); 
	paddingtop = (windowHeight-loginpanelHeight)/2;
	paddingtop1 = (windowHeight-rightpanelHeight)/2;
	j$('#leftcolumn').css('min-height', finalHeight);
	j$('#rightcolumn').css('min-height', finalHeight);
	j$('#loginpanel').css('padding-top', paddingtop);
	j$('#rightPanel').css('padding-top', paddingtop1);
}

function getHTML(a){
	
	return $scope.trustSrcHTML($compile(a));
}

/*function setCollapseIcon(elementId){		
	j$('#'+elementId).find("span.togglePageBlock").toggleClass('fa-caret-down fa-caret-up');	
}*/

function closeFlexModal(){
	j$('#'+$scope.flexTableId+'modalDiv').modal('hide') ;
	angular.element(document.getElementById($scope.flexTableId)).scope().getPageRecords();
	angular.element(document.getElementById($scope.flexTableId)).scope().$apply();
}

// the winURL should be in this format - /apex/<PageName>?id=<ID>&header=<MODAL HEADER>&tableId=<FLEXTABLENAME>
function openFlexModal(url ){
	angular.element(document.getElementById($scope.flexTableId)).scope().openModalFromHTML(url);
	angular.element(document.getElementById($scope.flexTableId)).scope().$apply();
}

function loadingScreen(){
	j$.blockUI(
		{
			message: '<img src="/img/loading.gif" alt="Loading gif"/>'
		}
	);
	setTimeout(j$.unblockUI, 5000);
}

var userTimeZone = 0;
function formatLocalDt(dateObj) {
		tzo = -dateObj.getTimezoneOffset(),
		dif = tzo >= 0 ? '+' : '-',
		pad = function(num) {
			var norm = Math.abs(Math.floor(num));
			return (norm < 10 ? '0' : '') + norm;
		};
	return dateObj.getFullYear()
		+ '-' + pad(dateObj.getMonth()+1)
		+ '-' + pad(dateObj.getDate());
}

function formatLocalDate(dateObj) {
	tzo = -dateObj.getTimezoneOffset(),
	dif = tzo >= 0 ? '+' : '-',
	pad = function(num) {
		var norm = Math.abs(Math.floor(num));
		return (norm < 10 ? '0' : '') + norm;
	};
	return dateObj.getFullYear()
	+ '-' + pad(dateObj.getMonth()+1)
	+ '-' + pad(dateObj.getDate())
	+ 'T' + pad(dateObj.getHours())
	+ ':' + pad(dateObj.getMinutes())
	//+ ':' + pad(dateObj.getSeconds())
	+ ':00'
	//+'Z' ;
	+ getUserOffset( userTimeZone );
}

function getUserOffset(s) {
	var ms = s % 1000;
	s = (s - ms) / 1000;
	var secs = s % 60;
	s = (s - secs) / 60;
	var mins = s % 60;
	var hrs = (s - mins) / 60;
	var absHrs = Math.abs(Math.floor(hrs));
	return (hrs>=0 ? '+' : '-' ) + (absHrs <10 ? '0'+absHrs :absHrs) + ':' + (mins <10 ? '0'+mins : mins) ;
}

function autoresizeIframe() {
  //  resizeIframe(null);
}

function resizeIframe(ifr) {
	var iframe = j$("[id$='iframeContentId']");
}

function resizeParent(docHeight){
	if(resizeFlag){		
		j$('iframe').css('height', docHeight);
	}
}

function autoResize(id){	
	var newheight;
	var newwidth;
	if(document.getElementById(id) != null){
		newheight = document.getElementById(id).contentWindow.document.body.scrollHeight;
		newwidth = document.getElementById(id).contentWindow.document.body.scrollWidth;
	}
	if(newheight != null)
		document.getElementById(id).height = (newheight) + "px";
	if(newwidth != null)
		document.getElementById(id).width = (newwidth) + "px";
}

function PreventEnter(e) {                                       
	   if (e.which == 13) {
			e.preventDefault();
			//do something   
	   }
}

function closeModalAndRefreshFlexTable(flextablId, message) {
	angular.element(document.getElementById(flextablId+'modalDivCloseIcon')).trigger('click');	
	angular.element(document.getElementById(flextablId)).scope().messages.push({type: 'info',msg:message});
	angular.element(document.getElementById(flextablId)).scope().$apply();
}
function setFocusOnCloseModal(){	
	if(event.keyCode==27){		
		j$(lastFocus).focus();
    }	
}
function refreshAllFlexTables(){
	var listEle = $('.row.ng-scope');
	var scopes = [];
	for(var i =0; i < listEle.length; i++){
		if(listEle[i].id == 'flexTableDivId')
		{
			var scope = angular.element(listEle[i]).scope();
			scope.refresh();
		}
	}
	
}
var j$ = jQuery.noConflict();

var autoSuggestionObject = {};

flexTableApp.controller('FlexTableCtrl', function ($q, $scope, $window, $sce, $parse, Scopes, $timeout,$filter) {
	
	// Get all the variables from the component
	Scopes.store('FlexTableCtrl', $scope);									 
	$scope.flexTableId = Scopes.get('MasterFlexTableCtrl').flexTable_TableId;
	$scope.uniqueSessionId = Scopes.get('MasterFlexTableCtrl').flexTable_uniqueSessionId;
	$scope.headerDescription = Scopes.get('MasterFlexTableCtrl').flexTable_headerDescription;
	$scope.timeOffset = Scopes.get('MasterFlexTableCtrl').flexTable_timeOffset;
	$scope.isInsideDynamicLayout = Scopes.get('MasterFlexTableCtrl').flexTable_insideDynamicLayout;
	$scope.currentPageURL = decodeURIComponent(Scopes.get('MasterFlexTableCtrl').flexTable_currentPageURL);	
	$scope.currentPageURLButtons = decodeURIComponent(Scopes.get('MasterFlexTableCtrl').flexTable_currentPageURLButtons);	
	$scope.flexTable_dataTableConfigName = Scopes.get('MasterFlexTableCtrl').flexTable_dataTableConfigName;
	$scope.flexTable_isPreview = Scopes.get('MasterFlexTableCtrl').flexTable_isPreview;
	$scope.flexTable_isFieldHistoryFlexTable = Scopes.get('MasterFlexTableCtrl').flexTable_isFieldHistoryFlexTable;	
	$scope.flexTable_keyValueMap = Scopes.get('MasterFlexTableCtrl').flexTable_keyValueMap;
	$scope.flexTable_listKeyValueMap = Scopes.get('MasterFlexTableCtrl').flexTable_listKeyValueMap;	
	$scope.flexTable_searchTerm = Scopes.get('MasterFlexTableCtrl').flexTable_searchTerm;
	$scope.flexTable_gridSearchTerm = Scopes.get('MasterFlexTableCtrl').flexTable_gridSearchTerm;	
	$scope.flexTable_objectName = Scopes.get('MasterFlexTableCtrl').flexTable_objectName;
	$scope.flexTable_phaseName = Scopes.get('MasterFlexTableCtrl').flexTable_phaseName;
	$scope.flexTable_sObjectOfFieldHistory = Scopes.get('MasterFlexTableCtrl').flexTable_sObjectOfFieldHistory;	
	$scope.flexTable_parentRecord = Scopes.get('MasterFlexTableCtrl').flexTable_parentRecord;
	$scope.flexTable_isN2GGridSearch = Scopes.get('MasterFlexTableCtrl').flexTable_isN2GGridSearch;
	$scope.flexTable_filterClauseGridSearch = Scopes.get('MasterFlexTableCtrl').flexTable_filterClauseGridSearch;	
	$scope.flexTable_skipNavTabName = Scopes.get('MasterFlexTableCtrl').flexTable_skipNavTabName;
	$scope.singleRecordSelection = Scopes.get('MasterFlexTableCtrl').flexTable_singleRecordSelection;
	$scope.pageLayoutName = Scopes.get('MasterFlexTableCtrl').flexTable_pgLayoutName;
	$scope.hideButton=true;
	
	/* Static data relevant to flex table */
	$scope.alphabets = ['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','All'];
	$scope.pageSizes = [];
	$scope.sortInfo  = { fields: [], directions: ['desc', 'asc']};
	$scope.isRefresh = false;
	$scope.searchTerm = '';
	$scope.errorCreatingTable = false;
	$scope.messages = [];
	$scope.isSOSL = false;
	$scope.flex = true;
	$scope.showStickySearchTextBox = true;
	$scope.hideRowLevelAction = false;
	$scope.initialParameters = {};
	$scope.searchTest = 'true';
	$scope.StickyObjectName = '';
	$scope.StickySearchCriteria=''; 
	$scope.showCollapsed = true;
	$scope.stickySearchJSON = '';    
	$scope.StickyUserSelection = ''; 
	$scope.hiddencolumns = [];
	$scope.parentScope = $scope;
	$scope.QuickSearchReportText = ''; 
	$scope.URLParams = window.location.search;
	$scope.hideHeader = true;
	$scope.isFilterCriteriaChanged = false;
	$scope.massEditableGridConfigJSON={};
	$scope.pagesizecheck = '';

	$scope.togglePanels = function(event) {
		setTimeout(function(){if(modalHandler(15) != undefined){modalHandler(15);}},300);
		var id= event.currentTarget.id;
		j$('#'+id).find("span.togglePageBlock").toggleClass('fa-caret-down fa-caret-up');
		$scope.hideButton = !$scope.hideButton;
    }
	
	if($scope.currentPageURLButtons.indexOf('&retURL') != -1){		
		$scope.currentPageURLButtons = $scope.currentPageURLButtons.substring(0, $scope.currentPageURLButtons.indexOf('&retURL'));		
	}
	if($scope.currentPageURL.indexOf('&retURL') != -1){
		$scope.currentPageURL = encodeURIComponent($scope.currentPageURL.substring(0, $scope.currentPageURL.indexOf('retURL')));
	}
	$scope.retURL = '?retParams='+ $scope.URLParams.substring(1,$scope.URLParams.length) + '&retURL=' + encodeURIComponent($scope.currentPageURL);
	
	$scope.data = {
		historyObj: ''		
    };
   
	$scope.aside = {title: 'Title', content: 'Hello Aside<br />This is a multiline message!'};
	$scope.exportOptionForPDF = [
							{title:"Download as PDF",exportAs:"PDF",imageURL:flexTable_PDf,
							pageURL:"/apex/" + namespace + "FlexTableExport?flexTableName="+$scope.flexTable_dataTableConfigName +"&mode=pdf&filterClause="+$scope.newFilterClause}
							];
	$scope.exportOptionForCSV = [
							{title:"Download as CSV",exportAs:"CSV",imageURL:flexTable_xl,
							pageURL:"/apex/" + namespace + "FlexTableExport?flexTableName="+$scope.flexTable_dataTableConfigName +"&mode=text/csv&filterClause="+$scope.newFilterClause},
							];
	
	$scope.fiscalYearOptions = [];
	$scope.clearStickySearch = false;
	
	$scope.actionIcon = function(){
	  return $scope.trustSrcHTML('<i class="fa fa-angle-double-down"> </i>');
	}

	$scope.trustSrcHTML = function(src) {
		return $sce.trustAsHtml(src);
	}
	
	$scope.addSpacecToMultiselect = function(src) {
		if(src != undefined){
			$scope.newString = src.replace(/;/g,"; ");
			return $sce.trustAsHtml($scope.newString);
		}
	}

	$scope.addEncryptedVal = function(src){
	   var encrptText = '';
	   console.log('New Val to Encrp--->',src);
       if(src != undefined && src != ''){
          for(var i=0;i<src.length;i++){
             encrptText += 'X';
          }   
       }
       return encrptText;
	}
	
	$scope.getHideDecision = function(record,rowActionItem){
		var obj = record;               
		viewValueGetter = $parse(rowActionItem.hideDecisionField);
		console.log('rowrecord:===>',record);               
		var hideDecisionFieldValue = viewValueGetter(obj); 
		var result = false;
		console.log('ActionName:===',rowActionItem.name);
		console.log('Action:===',rowActionItem);
		if(rowActionItem.hideOperator == undefined){
			rowActionItem.hideOperator = 'AND';
		}
		console.log('hideDecisionFieldValue:=',hideDecisionFieldValue);
		if(rowActionItem.hideAction != 'null' && (hideDecisionFieldValue == 'null'|| hideDecisionFieldValue == null) ){
			result = rowActionItem.hideAction;
		}else if (rowActionItem.hideAction == 'null' && hideDecisionFieldValue != 'null'){
			console.log('-------------rowActionItem.hideAction == null && hideDecisionFieldValue != null');
			result = hideDecisionFieldValue;
		}else if(rowActionItem.hideAction == 'null' && hideDecisionFieldValue == 'null'){
			result = false;
		}
		else{
			var result = (hideDecisionFieldValue != 'null' ? rowActionItem.hideOperator == 'AND'? hideDecisionFieldValue && rowActionItem.hideAction : hideDecisionFieldValue  || rowActionItem.hideAction : hideDecisionFieldValue);
        	console.log('result after operator cal:=',result);  
			
		}
		console.log('result after final:=',result);
		return result;
		}
	
	
	
	$scope.showHelpTooltip =function(thisVal,thm,id) {		                  
		j$('#'+id+'tooltip').tooltipster({ 
			 theme: thm,                     
			 multiple: true,
			 position : 'right',
			 animation :'fade',          
			 contentAsHTML: true,    
			 content : '<span>'+ thisVal + '</span>'
		});    
		j$('#'+id+'tooltip').tooltipster('show');    
	}
	$scope.hideHelpTooltip =function(thisVal,thm,id) {		                  		
		j$('#'+id+'tooltip').tooltipster('hide');    
	}
	$scope.exportTable = function(exportInfo){
		var d = new Date();
		var n = d.toLocaleDateString()+'__'+d.toLocaleTimeString();
		$window.open(encodeURI(exportInfo.pageURL+"&flexTableParam="+$scope.flexTable_keyValueMap+"&flexTableHeader="+$scope.flexTableHeader+"&locale="+n),"_blank");
	}
	$scope.redirect = function(tableConfigInfos){
		$window.open("/"+tableConfigInfos.FlexTableRecordId+"?isdtp=vw");
	}
	$scope.checkCookie = function() {
		return j$.cookie('setup') == 'present';
	}
	$scope.toUTCDate = function(date){
		var _utc = new Date(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate(),  date.getUTCHours(), date.getUTCMinutes(), date.getUTCSeconds());
		return _utc;
	};
	$scope.getDateTime = function(value){		
		var time = undefined;
		if(value != undefined){			
			return $scope.toUTCDate(new Date(value+$scope.timeOffset));
		}
		
		return time;
	};
	$scope.getDate = function(value){
		var time = undefined;
		if(value != undefined){
			return $scope.toUTCDate(new Date(value));
		}
		return time;
	};
	$scope.openPDFOrCSV = function(pdfOrCsv){
		if(pdfOrCsv=='PDF'){
			$window.open("/apex/" + namespace + "FlexTableExport?flexTableName="+$scope.flexTable_dataTableConfigName +"&mode=pdf&filterClause="+$scope.newFilterClause,"_blank");
		}
		else if(pdfOrCsv=='CSV'){
			$window.open("/apex/" + namespace + "FlexTableExport?flexTableName="+$scope.flexTable_dataTableConfigName +"&mode=text/csv&filterClause="+$scope.newFilterClause,"_blank");
		}
	}
	
	$scope.calculateTotalRowValues = function(recordList,columnName){               
		var total = 0;		
		for(var i= 0 ; i<recordList.length ;i++){
			var obj = recordList[i];			
			viewValueGetter = $parse(columnName);			
			var fieldValue = viewValueGetter(obj);
			if(!isNaN(fieldValue)){									
				total += Number(fieldValue);                        
			}
		}					  			    
		total = total.toFixed(2).replace(/(\d)(?=(\d{3})+(?!\d))/g, "$1,");
		total = '$' + total;
		return total;
	};
	
	
	/* Initialize the arrays that will be required here after */
	$scope.columns = [];
	
	/*Advance filter variables*/
	$scope.columnsFilter = [];
	$scope.filterDisplayList = [];
	$scope.filterDisplayListUniquenessTracker = {};
	$scope.filterValue = {};
	$scope.newFilterClause = '';
	$scope.advFilterClause = '';
	$scope.filterClause = '';
	$scope.quickSearchFilterClause = '';
	$scope.advanceFilterDisplayMap = {};
	$scope.selectedFilterOperator = {};
	
	$scope.pickListMap = {};
	$scope.pickListValueLabelMap = {};
	$scope.filterMap = {};
	$scope.filterDisplayMap = {};
	$scope.filterDisplayMapOnFilter = {};
	$scope.selectedRecords = {};
	$scope.flagForRenderPDFCSVButton = false;
	$scope.isStickySelectionChanged = false;
	$scope.quickSearchHelpText = '';
	$scope.initilizeDisplayMap = function() {
		angular.copy($scope.filterDisplayMap, $scope.filterDisplayMapOnFilter);
		//$scope.filterDisplayMapOnFilter = {};
		for(column in $scope.columns) {
			//$scope.columns[column].field
			$scope.columns[column].term1 = '';
			$scope.columns[column].term2 = '';
			if( $scope.filterDisplayMapOnFilter[$scope.columns[column].field] != undefined ) {
				$scope.columns[column].term1 = $scope.filterDisplayMapOnFilter[$scope.columns[column].field].val1;
				$scope.columns[column].term2 = $scope.filterDisplayMapOnFilter[$scope.columns[column].field].val2;
			}
		}
	}

	/* Functions that will be invoked across various actions */
	$scope.selectRecord = function(recordId,selectVal){
		if( $scope.singleRecordSelection ) {
			$scope.selectedRecords = {};
			$scope.selectedRecords[recordId] = selectVal;
		} else {
			$scope.selectedRecords[recordId] = selectVal;
			$scope.setSelectAllCheckBox();
		}
	}
	$scope.setSelectAllCheckBox = function(){
		var totalCount = 0;
		for(i=0;i<$scope.tableData.length;i++){
			var record = $scope.tableData[i];
			if($scope.selectedRecords[record.Id] == true){
				totalCount++;
			}
		}
		if(totalCount == $scope.tableData.length && $scope.tableData.length != 0){
			$scope.selAllChkBox = true;
		}else{
			$scope.selAllChkBox = false;
		}
	}
	$scope.selectAllRecords =function(selectVal){
		for(i=0;i<$scope.tableData.length;i++){
			var record = $scope.tableData[i];
			if(record[$scope.tableConfigInfo.HideDecisionForRecordSelection] != true){
				$scope.selectedRecords[record.Id] =  selectVal;
			}
		}
		$scope.selAllChkBox = selectVal;
	}
	$scope.closeAlert = function(index) {
		$scope.messages.splice(index, 1);
	};
	$scope.first = function(hasPrevious){
		if(hasPrevious == true){
			$scope.messages = [];
			showLoadingPopUp();
			$scope.pageNumber = 1;
			$scope.getPageRecords();
			$scope.setCookiesData();	
		}
	};
	$scope.last = function(hasNext){
		if(hasNext == true){
			$scope.messages = [];
			showLoadingPopUp();
			$scope.pageNumber = $scope.totalPages;
			$scope.getPageRecords();
			$scope.setCookiesData();
		}
		
	};
	$scope.next = function(hasNext){
		if(hasNext == true){
		    $scope.messages = [];	
			showLoadingPopUp();
			$scope.pageNumber++;
			$scope.getPageRecords();
			$scope.setCookiesData();
		}
	};
	$scope.previous = function(hasPrevious){
		if(hasPrevious == true){
			$scope.messages = [];
			showLoadingPopUp();
			$scope.pageNumber--;
			$scope.getPageRecords();
			$scope.setCookiesData();
		}
		
	};
	$scope.refresh = function(size){
		showLoadingPopUp();
		$scope.messages = [];
		if(size != undefined){
			$scope.pageSize = size;
			if(size == 'All'){
				$scope.pageSize = $scope.totalRecordsCount;
			}
		}
		$scope.pageNumber = 1;
		$scope.getPageRecords();
		$scope.setCookiesData();
		$scope.frame = document.getElementById($scope.flexTableId+'iframeContentId');
		j$("#"+$scope.flexTableId+"iframeContentId").height(100);
		if($scope.frame != null)
			$scope.frameDoc = $scope.frame.contentDocument || $scope.frame.contentWindow.document;
		if($scope.frameDoc != null)
			$scope.frameDoc.documentElement.innerHTML = "";
	};
	$scope.searchByIndex = function(indexVal){
		if(indexVal == 'All'){
			$scope.clearAllFilter();
		}else{
			var fieldName = $scope.sortFieldName;
			if(fieldName != undefined){
				$scope.filterStringRecords(fieldName,fieldName,'Starts with',indexVal,false);
				$scope.filterRecords();
			}
		}
	};
	$scope.quickSearchCall = function( searchTerm, event ){
		$scope.QuickSearchReportText = searchTerm;
		console.log('----prem---4---',searchTerm);
		if( event == null || event.keyCode == 13 ) {
			if(event!=null && event.keyCode == 13 ) {
				event.preventDefault();
			}
			showLoadingPopUp();
			console.log('----prem---3---',searchTerm);
			$scope.generateFilterString(searchTerm);
			$scope.getPageRecords();
		}
	};
	$scope.filterStringRecords = function(fieldName,label,criteria,searchTerm,isQuickSearch){
		var conditionString = '';
		if(fieldName != '' && criteria != '' && searchTerm != undefined && searchTerm != '' && criteria != undefined){
			conditionString = (criteria == 'Contains') ? (fieldName + ' LIKE \'%' +  searchTerm + '%\'') :
								(criteria == 'Ends with') ? (fieldName+ ' LIKE \'%' +  searchTerm + '\'') :
								(criteria == 'Starts with') ? (fieldName+ ' LIKE \'' +  searchTerm + '%\'') :
								(criteria == 'Equals') ? (fieldName+ ' = \'' +  searchTerm + '\'') :
								(criteria == 'Not equals') ? (fieldName+ ' != \'' +  searchTerm + '\'') :
								(fieldName+ ' = \'' +  searchTerm + '\'');
			if(!isQuickSearch) {
				$scope.filterMap[fieldName] = conditionString;
				$scope.filterDisplayMapOnFilter[fieldName] = {"label":label,"criteria":criteria + ' ' +searchTerm,"val1":criteria,"val2":searchTerm };
			}
		} else if(!isQuickSearch && searchTerm == '') {
			delete $scope.filterMap[fieldName];
			delete $scope.filterDisplayMapOnFilter[fieldName];
		}
		return conditionString;
	};
/*	$scope.generateQuickSearchFilter = function( searchTerm ){
		if( searchTerm != '' && searchTerm != undefined ) {
			searchTerm = searchTerm.replace("*", "%");
			var filterClause='';
			for(column in $scope.columns) {
				if($scope.columns[column].isFilterable == false) {
					break;
				}
				if($scope.columns[column].type == 'REFERENCE' || $scope.columns[column].type == 'PICKLIST' || $scope.columns[column].type == 'STRING' || $scope.columns[column].type == 'EMAIL' || $scope.columns[column].type == 'PHONE' || $scope.columns[column].type == 'URL') {
					if( column != "1" ) {
						filterClause += ' OR ';
					}
					filterClause +=$scope.filterStringRecords($scope.columns[column].field, $scope.columns[column].field, 'Contains', searchTerm, true);
				}else if($scope.columns[column].type == 'DATE' || $scope.columns[column].type == 'DATETIME' ) {
					var numbers = /^[0-9]+$/;
					var dateRE = /^(0[1-9]|1[0-2])\/(0[1-9]|1\d|2\d|3[01])\/(19|20)\d{2}$/;
					var dateREWithDateAndMonth = /^(0[1-9]|1[0-2])\/(0[1-9]|1\d|2\d|3[01])$/;
					if(searchTerm.match(numbers)) {
						if( column != "1" ) {
							filterClause += ' OR ';
						}
						filterClause +=  $scope.getDateQueryForQuickSearch($scope.columns[column].field, searchTerm);
					} else if(searchTerm.match(dateRE)) {
						if( column != "1" ) {
							filterClause += ' OR ';
					}
						filterClause +=  $scope.getFullDateQueryForQuickSearch($scope.columns[column].field, searchTerm);
					} else if(searchTerm.match( dateREWithDateAndMonth )) {
						if( column != "1" ) {
							filterClause += ' OR ';
						}
						filterClause +=  $scope.getMonthAndDayDateQueryForQuickSearch($scope.columns[column].field, searchTerm);
					}

				}else if($scope.columns[column].type == 'CURRENCY' || $scope.columns[column].type == 'DOUBLE') {
					var numbers = /^[0-9]+$/;
					if(searchTerm.match(numbers)) {
						if( column != "1" ) {
							filterClause += ' OR ';
						}
						filterClause +=  $scope.getNumberQueryForQuickSearch($scope.columns[column].field, searchTerm);
					}
				}
			}
			if( filterClause != '' ) {
				// if( $scope.quickSearchFilterClause != null && $scope.quickSearchFilterClause != '' ) {
				// 	$scope.quickSearchFilterClause = '( ' + $scope.quickSearchFilterClause + ' ) and ( ' + filterClause + ' )';
				// } else {
				// 	$scope.quickSearchFilterClause = '' + filterClause;
				// }
				$scope.quickSearchFilterClause = '' + filterClause;
			}

			console.log('$scope.quickSearchFilterClause---',$scope.quickSearchFilterClause);
			$scope.isSOSL = false;
		}else{
			$scope.quickSearchFilterClause = '';
		}
	}
*/	
	$scope.generateQuickSearchFilter = function( searchTerm ){
		console.log('--prem--2--',searchTerm);
		if( searchTerm != '' && searchTerm != undefined ) {
			searchTerm = searchTerm.replace("*", "%");
			var filterClause='';
			var finalFilterClause = '';
			for(column in $scope.columns) {
				console.log('$scope.columns----528------>',$scope.columns);
				console.log('$scope.columns----528------>',column);
				if($scope.columns[column].isFilterable == true){					
					if($scope.columns[column].isFilterable == false) {
						break;
					}
					if($scope.columns[column].type == 'TEXTAREA' || $scope.columns[column].type == 'REFERENCE' || $scope.columns[column].type == 'PICKLIST' || $scope.columns[column].type == 'STRING' || $scope.columns[column].type == 'COMBOBOX' || $scope.columns[column].type == 'EMAIL' || $scope.columns[column].type == 'PHONE' || $scope.columns[column].type == 'URL') {
						filterClause =$scope.filterStringRecords($scope.columns[column].field, $scope.columns[column].field, 'Contains', searchTerm, true);
					}else if($scope.columns[column].type == 'DATE' || $scope.columns[column].type == 'DATETIME' ) {
						var numbers = /^[0-9]+$/;
						var dateRE = /^(0[1-9]|1[0-2])\/(0[1-9]|1\d|2\d|3[01])\/(19|20)\d{2}$/;
						var dateREWithDateAndMonth = /^(0[1-9]|1[0-2])\/(0[1-9]|1\d|2\d|3[01])$/;
						if(searchTerm.match(numbers)) {
							filterClause =  $scope.getDateQueryForQuickSearch($scope.columns[column].field, searchTerm);
						} else if(searchTerm.match(dateRE)) {
							filterClause =  $scope.getFullDateQueryForQuickSearch($scope.columns[column].field, searchTerm);
						} else if(searchTerm.match( dateREWithDateAndMonth )) {
							filterClause =  $scope.getMonthAndDayDateQueryForQuickSearch($scope.columns[column].field, searchTerm);
						}
					}else if($scope.columns[column].type == 'CURRENCY' || $scope.columns[column].type == 'DOUBLE') {
						var numbers = /^[0-9]+$/;
						if(searchTerm.match(numbers)) {
							filterClause =  $scope.getNumberQueryForQuickSearch($scope.columns[column].field, searchTerm);
							// filterClause = filterClause.replace(/[^0-9 ]/g, ""); /*Atul Commented this code on 19/05/2017*/
						}
					}
					
					if( filterClause != '' ){
						finalFilterClause += filterClause + ' OR ';
					}
					console.log('===> filterclause in loop '+finalFilterClause);
				}
			}
			
			filterClause = finalFilterClause;
			console.log('===> final filterclause '+filterClause);
			if( filterClause != '' ) {
				// if( $scope.quickSearchFilterClause != null && $scope.quickSearchFilterClause != '' ) {
				// 	$scope.quickSearchFilterClause = '( ' + $scope.quickSearchFilterClause + ' ) and ( ' + filterClause + ' )';
				// } else {
				// 	$scope.quickSearchFilterClause = '' + filterClause;
				// }
				filterClause = filterClause.substring(0,filterClause.length-4)
				console.log('===>  filterclause '+filterClause);
				$scope.quickSearchFilterClause = '' + filterClause;
			}

			console.log('$scope.quickSearchFilterClause---',$scope.quickSearchFilterClause);
			$scope.isSOSL = false;
		}else{
			$scope.quickSearchFilterClause = '';
		}
	}
		
	$scope.getDateQueryForQuickSearch = function(fieldName, searchTerm){
		return 'CALENDAR_MONTH('+fieldName+')='+searchTerm+' OR CALENDAR_YEAR('+fieldName+')='+searchTerm+' OR DAY_IN_MONTH('+fieldName+')='+searchTerm+' ';
	}

	$scope.getFullDateQueryForQuickSearch = function(fieldName, searchTerm){
		var searchSplit = searchTerm.split("\/");
		if( $scope.userOffset == undefined ) {
			$scope.userOffset = '0:0';
		}
		//$scope.toUTCDate
		var date = new Date();		
		date.setMonth(searchSplit[0]-1);
		date.setDate(searchSplit[1]);
		date.setYear(searchSplit[2]);
		date.setHours(0);
		date.setMinutes(0);
		
		var date1 = new Date(date.getTime() - userTimeZone );
		//console.log('====2=', date1);
		tmpVar = date1;
		return '( CALENDAR_MONTH('+fieldName+')='+( date1.getMonth() + 1) +' and CALENDAR_YEAR('+fieldName+')='+date1.getFullYear()+' and DAY_IN_MONTH('+fieldName+')='+date1.getDate()+') ';
	}

	$scope.getMonthAndDayDateQueryForQuickSearch = function(fieldName, searchTerm){
		var searchSplit = searchTerm.split("\/");
		return '( CALENDAR_MONTH('+fieldName+')='+searchSplit[0]+' and DAY_IN_MONTH('+fieldName+')='+searchSplit[1]+') ';
	}

	$scope.getNumberQueryForQuickSearch = function(fieldName, searchTerm){
		return fieldName + '='+searchTerm;
	}

	$scope.sort = function(column){
		
		if(column.type != 'TEXTAREA' && column.type != 'MULTIPICKLIST'){
			if(column.field != undefined){
				showLoadingPopUp();
				var fieldName = column.field;

				if($scope.sortFieldName == fieldName && ($scope.sortDirection == 'ASC' || $scope.sortDirection == 'asc')){
					$scope.sortDirection = 'desc';
				    
				}else if($scope.sortFieldName == fieldName && ($scope.sortDirection == 'DESC' || $scope.sortDirection == 'desc')){
					$scope.sortDirection = 'asc';
				    
				}else {
					$scope.sortDirection = 'asc';
					
				}
				$scope.sortFieldName = fieldName ;
				$scope.pageNumber = 1;
				if($scope.flexTable_searchTerm !='' && $scope.flexTable_objectName != '' && $scope.flexTable_phaseName != ''){
					$scope.isSkinnyTable = true;
					$scope.initFlexSkinnyTable();
				}else{
				$scope.getPageRecords();
				$scope.setCookiesData();
			}
				
			}
		} else{
			alert('Sorting is not supported on this column.');
		}
	}

	$scope.setCookiesData = function(column){
		if( $scope.sortFieldName != undefined && $scope.sortFieldName != '' ) {
			j$.cookie($scope.uniqueSessionId+"sortFieldName", $scope.sortFieldName );
		}
		if( $scope.sortDirection != undefined && $scope.sortDirection != '' ) {
			j$.cookie($scope.uniqueSessionId+"sortDirection", $scope.sortDirection );
		}
		if( $scope.pageNumber != undefined && $scope.pageNumber != '' ) {
			j$.cookie($scope.uniqueSessionId+"pageNumber", $scope.pageNumber );
		}
		/*if( $scope.pageSize != undefined && $scope.pageSize != '' ) {
			j$.cookie($scope.uniqueSessionId+"pageSize", $scope.pageSize);
		}*/
	}

	$scope.openHelp = function (){
		if($scope.tableConfigInfo.IsHelpDownloadable == 'true'){
			window.open('/servlet/servlet.FileDownload?file='+$scope.tableConfigInfo.HelpDocId,'_blank');
		}else{
			window.open('/apex/' + namespace + 'Help?id='+$scope.tableConfigInfo.Help, '_blank','width=900, height=700');
		}
	}

	$scope.regexForMergeFieldInConfirmMessage = function(confirmMsg,regexObj){
		var match = null;
		var regex = regexObj;///\{\!(\w*)\}/g;
		var matches = new Array();
		while (match = regex.exec(confirmMsg)) {
			var matchArray = [];
			for (i in match) {
				if (parseInt(i) == i) {
					matchArray.push(match[i]);
				}
			}
			matches.push(matchArray);
		}
		return matches;
	}
	$scope.openLinkFromSearch = function(rowActionInfo,row,isTopItem){		
		rowActionInfo.actionBehavior = 'Open in new window';		
		$scope.openLink(rowActionInfo,row,isTopItem);	
	}
	$scope.openLink = function(rowActionInfo,row,isTopItem){
		$scope.messages = [];
		
		if(rowActionInfo.showConfirmationBox ){
			var count = 0;
			var selectedRecord;
			var selectedRecordIdCount;
			var targetUser;
			var confirmMsg = rowActionInfo.confirmationMessage;
			
			if($scope.FlexTableMetaData.ConfigInfo.EnableRecordSelection==true){
				for(selectedRecord in $scope.selectedRecords){
					if($scope.selectedRecords[selectedRecord]){
						count++; 
						
					}
				}
				
				if(count == 0) {					
					alert('Please select atleast one record.');
					hideLoadingPopUp();
					throw new Error('Please select atleast one record');
				}
			}
			var regex = /\{\!(\w*)\}/g;
			var value;
			var matches = $scope.regexForMergeFieldInConfirmMessage(confirmMsg,regex);
			selectedRecordIdCount = count;
			for(array in matches){
				value = matches[array][1];
				if(selectedRecordIdCount != undefined && value == "selectedRecordIdCount"){
					confirmMsg = confirmMsg.replace(matches[array][0],selectedRecordIdCount);
				}else if($scope.keyValueMap[value] != undefined ) {
					confirmMsg = confirmMsg.replace(matches[array][0],$scope.keyValueMap[value]);
				}
				else{
					confirmMsg = confirmMsg.replace(matches[array][0],'');
				}
			}
			$scope.showConfirmBox(confirmMsg,rowActionInfo,row,isTopItem, false);
		}else{
			$scope.openLink2(rowActionInfo,row,isTopItem);
		}
	}
	
	$scope.openLink2 = function(rowActionInfo,row,isTopItem){
		//if($scope.methodCalled == true){
			//$scope.methodCalled = false;
			$scope.messages = [];
			var winURL = '';
			if(rowActionInfo.actionURL != 'null'){
				if(rowActionInfo.standardAction.toLowerCase() == 'new'){
					if(rowActionInfo.actionURL != null && rowActionInfo.actionURL != ''){
						var winURL = rowActionInfo.actionURL;

					}
				}else if(rowActionInfo.standardAction.toLowerCase() == 'edit'){
					if(rowActionInfo.actionURL != null && rowActionInfo.actionURL != ''){
						var winURL = rowActionInfo.actionURL;
						if(row != null){
							var objName = $scope.objectName;
							var mergeField = '{' + '!' + objName  + '.id}';
							winURL = winURL.replace(new RegExp('(' + mergeField + ')', 'gi'), row.Id);

						}
						if(row != null){
							var objName = $scope.objectName;
							var mergeField = '{' + '!' + objName  + '.Name}';							
							winURL = winURL.replace(new RegExp('(' + mergeField + ')', 'gi'), row.Name);
						}
					}
				}else{
					//hideLoadingPopUp();
					var winURL = rowActionInfo.actionURL;
					if(row != null){
						var objName = $scope.objectName;
						var mergeField = '{' + '!' + objName  + '.id}';
						winURL = winURL.replace(new RegExp('(' + mergeField + ')', 'gi'), row.Id);
					}
					if(row != null){
					   // Merger Field For Action Url Form Config Part
						var reg = new RegExp(/{\![^}\.]*\.(.[^}]*)\}/);
						var result;
						while ((result = reg.exec(winURL)) !== null) {
							if(result[1].lastIndexOf('\.') > -1) {
							    var obj = row;
							    valueGetter = $parse(result[1]);
							    var viewValue = valueGetter(obj);
								//var splitList = result[1].split('\.');
								if(viewValue == undefined){
                                   viewValue = '';
								}
						        winURL = winURL.replace(result[0], viewValue);										
								//winURL = winURL.replace(result[0], row[splitList[0]][splitList[1]]);
							} else {
								winURL = winURL.replace(result[0], row[result[1]]);
							}
						}
					}
					if($scope.tableConfigInfo.EnableRecordSelection == 'true'){
						var idsParam='';
						if(winURL.indexOf('?') == -1){
							idsParam += '?';
						}else{
							idsParam += '&';
						}
						idsParam += 'ids=';
						for(id in $scope.selectedRecords){
							if($scope.selectedRecords[id] == true){
								idsParam += id + ',';
							}
						}
						idsParam = idsParam.substring(0,idsParam.length-1);
						winURL += idsParam ;
					}
				}
					//Prajakta:In winurl we pass 3 paramters that is tablename,refreshbehaviour and type.
					//This parameters are used in modalflexedit.
					if (winURL.indexOf("?") == -1) {
					console.log('rowActionInfo===',rowActionInfo);
                		winURL = winURL + '?RefreshBehaviour='+rowActionInfo.refreshBehaviour+'&TableName='+$scope.flexTableId+'&TableType=flextable';
           			 } else {
                		winURL = winURL + '&RefreshBehaviour='+rowActionInfo.refreshBehaviour+'&TableName='+$scope.flexTableId+'&TableType=flextable';
           			 }
           			 console.log('winURLwinURL1111---->'+winURL);

            			

			}else if(rowActionInfo.actionClass != 'null'){
				if(isTopItem == true){
					if($scope.tableConfigInfo.EnableRecordSelection == 'true' && $scope.selectedRecords != undefined && $scope.selectedRecords != ''){
						$scope.executeApexClass(rowActionInfo,$scope.selectedRecords,$scope.keyValueMap);
						$scope.selectedRecords = {};
					}else if($scope.tableConfigInfo.EnableRecordSelection == 'true' && $scope.selectedRecords == ''){
						$scope.messages.push({type: 'info',msg: 'Please select atleast one record.'});
					}else{
						$scope.selectedRecords = {};
						$scope.executeApexClass(rowActionInfo,$scope.selectedRecords,$scope.keyValueMap);
					   // $scope.selectedRecords = '';
					}
				}else{
					$scope.selectedRecord = {};
					if(row.Id != undefined){
						$scope.selectedRecord[row.Id] = true;
					}
					$scope.executeApexClass(rowActionInfo,$scope.selectedRecord,$scope.keyValueMap);
				}
			}
			if(winURL != '' && rowActionInfo.standardAction.toLowerCase() != 'delete'){
				$scope.handleOpenCondition(winURL,rowActionInfo);
			} else if(rowActionInfo.standardAction.toLowerCase() == 'delete'){
				if(row != null){
					if(rowActionInfo.confirmationMessage && rowActionInfo.showConfirmationBox){
						$scope.deleteRecords(row.Id,rowActionInfo);
					}else{
						var message = flexTable_DeleteConfirmLabel;
						$scope.showConfirmBox(message,rowActionInfo,row,isTopItem, true);
					}
				}
		   }
	}

	/* to show confirm boot box*/
	$scope.showConfirmBox = function(message,rowActionInfo,row,isTopItem, isDelete){
		
		bootbox.dialog({
			  message: message,
			  title:"Confirm",
			  onEscape: function() {},
			  backdrop: true,
			  closeButton: true,
			  animate: true,
			  buttons: {
				No: {   
				   label: "No",
				  callback: function() { }
				},
				"Yes": {
				  label: "Yes" ,
				  callback: function(result) {
					 if(result){
						//showLoadingPopUp();
						if(isDelete) {
							$scope.deleteRecords(row.Id,rowActionInfo);
						} else {
							$scope.openLink2(rowActionInfo,row,isTopItem);
						}
					}
				  }
				},
			  }
		});
	 }

	$scope.refreshTables = function(){
		var pageLayoutName = $scope.pageLayoutName;
		console.log('pageLayoutName--->>>',pageLayoutName);
		if(pageLayoutName != null && pageLayoutName != '') {
			Visualforce.remoting.Manager.invokeAction(
				_RemotingFlexTableActions.refreshTables,
				pageLayoutName,
				function(result, event) {
						if(event.type === 'exception') {						
						}
						else if (event.status) {						
							resetSession();
							
							if(result != null) {
								if(result.length > 0) {
									for(var i = 0; i< result.length; i++) {
										if(document.getElementById(result[i].trim()) != null) {
											$scope.$apply(function(){
												angular.element(document.getElementById(result[i].trim())).scope().$$childTail.refreshLayoutSpecificFlexTables();
											});
										}
									}
								}
							}
							if(result == 'Success') {
							}
							else {
							}
						}
						else {
							//console.log(event.message);
						}
				}
			);
		}
	}
	
	
	$scope.handleOpenCondition = function(winURL,rowActionInfo){

	   // winURL = decodeURIComponent(winURL);
		if(rowActionInfo.standardAction.toLowerCase() == 'edit' || rowActionInfo.standardAction.toLowerCase() == 'new'){
			if(winURL.toLowerCase().indexOf("saveurl")== -1){
				if(winURL.indexOf("?") == -1){
					winURL = winURL + '?saveURL='+encodeURIComponent($scope.currentPageURL);
				}else{
					winURL = winURL + '&saveURL='+encodeURIComponent($scope.currentPageURL);
				}
			}
		}
		if(winURL.indexOf('&retURL') != -1){
			winURL = winURL.substring(0, winURL.indexOf('retURL'));
		}
		var ret = decodeURIComponent($scope.currentPageURL);
		if(ret.indexOf('&retURL') != -1 || ret.indexOf('?retURL') != -1 ){
			ret = ret.substring(0, ret.indexOf('retURL')-1);
		}
		if(winURL.indexOf("?") == -1){
			winURL += '?retURL='+encodeURIComponent(ret);
		}else{
			winURL += '&retURL='+encodeURIComponent(ret);
		}

		//winURL = encodeURIComponent(winURL);

		if(rowActionInfo.actionBehavior == 'Open in same window'){
			showLoadingPopUp();
			$window.open(winURL,'_self');
		}else if(rowActionInfo.actionBehavior == 'Open in new window'){
			hideLoadingPopUp();
			$window.open(winURL,'_blank');
		}else if(rowActionInfo.actionBehavior == 'Open in overlay'){
			//table Id to hide and refresh it outside of scope
			winURL = winURL + '&parentTableId='+$scope.flexTableId;
			hideLoadingPopUp();
			$scope.windowURL = winURL ;
			if(rowActionInfo.modalTitle != 'null'){
				$scope.windowTitle =  rowActionInfo.modalTitle;
			}else{
				$scope.windowTitle = rowActionInfo.dataTableActionObj.Name ;
			}
			if(rowActionInfo.height != 'null' && rowActionInfo.height != ''){				
				$scope.windowDialogHeight = (parseInt(rowActionInfo.height)+50).toString() +'px';
				$scope.windowHeight = (parseInt(rowActionInfo.height)).toString() +'px';
				  resizeFlag=false;			 
			}else{
			   // $scope.windowHeight = '500px';
			  //  $scope.windowDialogHeight  = '550px';
				  resizeFlag=true;
			}
			if(rowActionInfo.width != 'null' && rowActionInfo.width != ''){
				if((parseInt(rowActionInfo.width)) < 100) {
					$scope.windowWidth  = (parseInt(rowActionInfo.width)).toString() + '%';
				} else {
					$scope.windowWidth  = (parseInt(rowActionInfo.width)).toString() +'px';
				}
			}else{
				$scope.windowWidth = '50%';
				$scope.windowContentWidth = '50%';
			}
			//loadingScreen();
			//showLoadingPopUp();
			j$('#'+$scope.flexTableId+'modalDiv').modal();
			//$scope.methodCalled = true;
			lastFocus = document.activeElement;
			flexModalId = $scope.flexTableId;
			
		}else{
			showLoadingPopUp();
			$window.open(winURL,'_self');
		}
		autoresizeIframe();
	}
	$scope.trustSrc = function(src) {
		return $sce.trustAsResourceUrl(src);
	}
	// the winURL should be in this format - /apex/<PageName>?id=<ID>&header=<MODAL HEADER>&tableId=<FLEXTABLENAME>
	$scope.openModalFromHTML = function(winURL){
		$scope.windowURL = '';
		var tableIdStartIndex = winURL.indexOf('&tableId=');
		var tableIdValue = winURL.substring(tableIdStartIndex+9);
		var headerValueStartIndex = winURL.indexOf('&header=');
		var headerValue = winURL.substring(headerValueStartIndex+8, tableIdStartIndex);
		$scope.windowURL = winURL ;
		$scope.windowTitle = headerValue;
		$scope.windowWidth = '1200px';
		$scope.windowContentWidth = '1170px';
		$scope.windowHeight = '800px';
		var modalId = '#'+tableIdValue+'modalDiv';		
		j$(modalId).modal();
	}

	$scope.executeApexClass = function(rowActionInfo,selectedRecords,keyValueMap){
		var winURL = '';
		var deferred = $q.defer();
		if(keyValueMap == undefined){
			keyValueMap =  {};
		}
		showLoadingPopUp();
		Visualforce.remoting.Manager.invokeAction(
			_RemotingFlexTableActions.ExecuteClass,
			rowActionInfo.actionClass,selectedRecords,keyValueMap,rowActionInfo.dataTableActionObj,$scope.flexTable_dataTableConfigName ,$scope.currentPageURLButtons,
			function(executeClassResult, event){
				if (event.status) {
					resetSession();
					$scope.$apply(function () {
						deferred.resolve(executeClassResult);
						winURL = executeClassResult.PageURL;
						$scope.messages = [];
						if(executeClassResult.Error != null && executeClassResult.Error != ''){
							hideLoadingPopUp();
							$scope.messages.push({type: 'danger',msg: '' + executeClassResult.Error});
							//alert(executeClassResult.Error);
							//$scope.methodCalled = true;
						}else if(winURL != null && winURL != ''){
						   $scope.handleOpenCondition(winURL,rowActionInfo);
						}else if(executeClassResult.Message != null && executeClassResult.Message != ''){
							var type = executeClassResult.type == undefined ? 'info' : executeClassResult.type;  //set type for error message.type
							$scope.messages.push({type: type,msg: executeClassResult.Message});
							if($scope.actionInfo[rowActionInfo.name].RefreshBehavior == 'Refresh the entire page') {
								window.location.reload();
							}else if($scope.actionInfo[rowActionInfo.name].RefreshBehavior == 'Refresh all flextables'){
								refreshAllFlexTables();
							}else if($scope.actionInfo[rowActionInfo.name].RefreshBehavior == 'Refresh parent page'){
								window.parent.location.reload();
							} else if($scope.actionInfo[rowActionInfo.name].RefreshBehavior == 'Close modal and refresh grid'){
                               if(modalFlexEditLayout_tableType == 'flexGrid'){
									//This method is added from flexgrid component. It is used to refresh grid.
									parent.refreshFlexGrid(modalFlexEditLayout_tableName);//angular.element(parent.document.getElementById('inlineEditGrid'+ flextableName)).scope().$$childTail.initInlineEditableGrid();	
								}else{
									//This method is added from flextable component. It is used to refresh flextable.
									parent.refreshFlexTable(modalFlexEditLayout_tableName,modalFlexEditLayout_refreshBehaviour);	
								}
                            }else {
								$scope.getPageRecords();
							}
							//$scope.getPageRecords(); // commented on 1-17-17
							//$scope.methodCalled = true;
							hideLoadingPopUp();
							$scope.selectedRecords = {};
						}else if(executeClassResult.RefreshParentPage != null && executeClassResult.RefreshParentPage == 'true') {
							window.parent.loacation.reload();
						}
					});
				}
			},
			{ buffer: false, escape: false, timeout: 30000 }
		);
	}
	
	$scope.deleteRecords = function(recordId,rowActionInfo) {			              
		Visualforce.remoting.Manager.invokeAction(
			_RemotingFlexTableActions.DeleteRecord,
			$scope.objectName, recordId,
			function(deleteResult, event) {
				if (event.status) {
					resetSession();
					$scope.$apply(function() {
						var deleteMessage;
						if (deleteResult.Success) {
							deleteMessage = deleteResult.Message;;
							if(rowActionInfo.RefreshBehavior == 'Refresh the entire page') {
		                        window.location.reload();
		                    }else if(rowActionInfo.RefreshBehavior == 'Refresh all flextables'){
		                    	$scope.refreshTables();
		                    }else if(rowActionInfo.RefreshBehavior == 'Refresh parent page'){
								window.parent.location.reload();
							} else if(rowActionInfo.RefreshBehavior == 'Close modal and refresh grid'){
                               if(modalFlexEditLayout_tableType == 'flexGrid'){
									//This method is added from flexgrid component. It is used to refresh grid.
									parent.refreshFlexGrid(modalFlexEditLayout_tableName);//angular.element(parent.document.getElementById('inlineEditGrid'+ flextableName)).scope().$$childTail.initInlineEditableGrid();	
								}else{
									//This method is added from flextable component. It is used to refresh flextable.
									parent.refreshFlexTable(modalFlexEditLayout_tableName,modalFlexEditLayout_refreshBehaviour);	
								}
                            }else {
		                    	$scope.getPageRecords();
		                    }
							$scope.messages.push({type: 'success',msg: '' + deleteMessage});
						} else {
							var result = deleteResult.Message;
							var deleteMessageArray = result.split(':');
							var deleteMessage = deleteMessageArray[2];
							var deleteErrorMessageArray = deleteMessage.split(',');
							deleteMessage = deleteErrorMessageArray[1];
							$scope.messages.push({type: 'danger',msg: '' + deleteMessage});
						}
						hideLoadingPopUp();
						var titleMessage = flexTable_AlertHeaderLabel;
						

						/*bootbox.dialog({
							size: 'small',
							message: deleteMessage,
							title: titleMessage,
							onEscape: function() {},
							backdrop: false,
							closeButton: true,
							animate: true,
							buttons: {
									ok: {
										label: "Ok",
										className: "customBtn btn-ext",
									}
								}
						});*/
					});
				}
			}, {
				buffer: false,
				escape: false,
				timeout: 30000
			}
		);

	};
	$scope.clearAllFilter = function(){
		$scope.filterMap = {};
		$scope.filterDisplayMap = {};		
		$scope.newFilterClause = '' + $scope.filterClause + $scope.quickSearchFilterClause;
		$scope.showFilterPane = false;
		$scope.getPageRecords();
	};
	$scope.removeFilter = function(field){
		delete $scope.filterMap[field];
		delete $scope.filterDisplayMap[field];
		if(_.size(angular.copy($scope.filterMap)) == 0){
			$scope.showFilterPane = false;
		}
		$scope.refreshAfterFilter();
	};
	$scope.filterRecords = function(){
		angular.copy($scope.filterDisplayMapOnFilter, $scope.filterDisplayMap);
		$scope.showFilterPane = true;
		$scope.refreshAfterFilter();
	};
	
	

	$scope.generateFilterString = function( quickSearchText ){
		var filterString = '';
		for(filter in $scope.filterMap){
			filterString += ' AND '+ $scope.filterMap[filter];			
		}
		if(filterString != '') {
			if($scope.quickSearchFilterClause != '') {
				$scope.quickSearchFilterClause = $scope.quickSearchFilterClause + filterString;
			}else{
				$scope.quickSearchFilterClause = filterString.substring(4,filterString.length);
			}
			console.log('---$scope.quickSearchFilterClause--',$scope.quickSearchFilterClause);
		}
		if($scope.StickySearchCriteria != ''){			
		}
		$scope.generateQuickSearchFilter(quickSearchText);
		$scope.newFilterClause = $scope.filterClause;
		var bitOperator = $scope.newFilterClause == '' ? '' : ' AND ';		
		var bracket = $scope.newFilterClause == '' ? '' : ' ( ';		
		if($scope.quickSearchFilterClause != ''){			
			$scope.newFilterClause = $scope.newFilterClause + bitOperator + ' (' + $scope.quickSearchFilterClause + ')';	
		}	
		bitOperator = $scope.newFilterClause == '' ? '' : ' AND ';		
		if($scope.advFilterClause != ''){
			$scope.newFilterClause = $scope.newFilterClause + bitOperator + ' (' + $scope.advFilterClause + ')';		
		} 
		$scope.newFilterClause = $scope.newFilterClause == undefined ? '' : $scope.newFilterClause;
		console.log('---$scope.newFilterClause--',$scope.newFilterClause);
		$scope.pageNumber = 1;
		
	};
	$scope.refreshAfterFilter = function(){
		showLoadingPopUp();
		$scope.generateFilterString( $scope.QuickSearchReportText );

		j$.removeCookie($scope.uniqueSessionId+'filterMapInst');
		j$.removeCookie($scope.uniqueSessionId+'filterDispMap');
		j$.cookie($scope.uniqueSessionId+"filterMapInst", JSON.stringify( $scope.filterMap ));
		j$.cookie($scope.uniqueSessionId+"filterDispMap", JSON.stringify( $scope.filterDisplayMap ));
		$scope.getPageRecords();
	};
	$scope.setLoading = function(loading) {
		$scope.isLoading = loading;
	};
	
	$scope.filterFlexTable = function(selectedFilter,index){                      
		/* Clearing all filters start */
		//jQueryMagicSuggest.clear();                  
		$scope.QuickSearchReportText = '';
		$scope.isFilterCriteriaChanged = true;  
		//console.log('autoSuggestionObject[$scope.flexTable_dataTableConfigName]--->>>',autoSuggestionObject[$scope.flexTable_dataTableConfigName]);
		//autoSuggestionObject[$scope.flexTable_dataTableConfigName ].clear();
		j$('#quickSearchText1').val(''); // ng-model is not restting hence jquery.                
		$scope.filterDisplayMapOnFilter = {};
		$scope.filterDisplayMap={};
		$scope.filterMap = {};
		j$.removeCookie($scope.uniqueSessionId+"filterDispMap");
		j$.removeCookie($scope.uniqueSessionId+'filterMapInst');
		//$scope.clearAllFilter();
		/* Clearing all filters end */
		for(var i =0 ;i<$scope.FlexTableFilterListViewValues.length ;i++) {
			$scope.FlexTableFilterListViewValues[i].isSelected = false;
		}
		$scope.FlexTableFilterListViewValues[index].isSelected = true;                
		$scope.isStickySelectionChanged = false;                
		$scope.filterClause  = selectedFilter.clause;                                                         
		$scope.updatedHeader = selectedFilter.label;
		$scope.generateFilterString('');
		$scope.getPageRecords();
		
		/*508-skip link */
		$scope.getNavLinks_InnerHtml2 = function(){
			if(document.getElementById($scope.flexTable_dataTableConfigName+'SkipLink') != undefined){
				document.getElementById($scope.flexTable_dataTableConfigName+'SkipLink').innerHTML = 'Skip to ' +$scope.updatedHeader;			 				
			}
			if(document.getElementById($scope.flexTableId+'SkipLink') != undefined){
				document.getElementById($scope.flexTableId+'SkipLink').innerHTML = 'Skip to ' +$scope.updatedHeader;				 
			}			 
		};
		$scope.getNavLinks_InnerHtml2();
	}

	$scope.updateFlexHeader = function(){
		if($scope.FlexTableFilterListViewValues){
			for(var i=0;i<$scope.FlexTableFilterListViewValues.length ;i++){
				if($scope.FlexTableFilterListViewValues[i].isSelected == true){
					return $scope.FlexTableFilterListViewValues[i].label;
				}
			}
		}                
	}
	$scope.getCounter = function(row,column){
		$scope.counter = $scope.counter == undefined ? 0 : $scope.counter+1;                                		
	}
	
	$scope.selectedFilterOperator = {};
	$scope.selectedFilterColumn = {};
	$scope.setOperator = function(selectedOperator){
		$scope.selectedFilterOperator.value = selectedOperator;		
	}
	$scope.advanceFilterOption = function(selectedFilterColumn){
		$scope.filterTerm = undefined;
		$scope.selectedFilterColumn.value = selectedFilterColumn;
		$scope.filterValue.selectedFilterColumn = selectedFilterColumn;
		$scope.filterValue.templateValue = '';
		console.log('$scope.selectedFilterColumn.value.type---',$scope.selectedFilterColumn.value.type);
		$scope.filterValue.type = selectedFilterColumn.type;
		if($scope.selectedFilterColumn.value.field == $scope.StickySearchFieldApiName){
			$scope.inputOperatorFilterOptions2 = [
                {'label':'Equals to', 'value':'='},                    
                {'label':'Not equals to', 'value':'!='}
            ];    
            
            $scope.stickySearchFilterClause = $scope.filterClause;
            if($scope.quickSearchFilterClause != ''){
            	$scope.stickySearchFilterClause += ' AND ( ' + $scope.quickSearchFilterClause + ')' ;
            }             
            $scope.inputOperatorFilterOptions = $scope.inputOperatorFilterOptions2;
            console.log('$scope.stickySearchFilterClause--',$scope.stickySearchFilterClause);
    	}else if($scope.selectedFilterColumn.value.type == 'DATETIME') {
			$scope.inputOperatorFilterOptions4 = [
				{'label':'Greater than', 'value':'>'},
				{'label':'Less than', 'value':'<'},
				{'label':'Greater than or Equal to', 'value':'>='},
				{'label':'Less than or Equal to', 'value':'<='}
			];		
			$scope.inputOperatorFilterOptions = $scope.inputOperatorFilterOptions4;					
		}else if( $scope.selectedFilterColumn.value.type == 'DATE' || $scope.selectedFilterColumn.value.type == 'CURRENCY' 
				|| $scope.selectedFilterColumn.value.type == 'DOUBLE' || $scope.selectedFilterColumn.value.type == 'INTEGER' || $scope.selectedFilterColumn.value.type == 'PERCENT') {
			$scope.inputOperatorFilterOptions1 = [
				{'label':'Equals to', 'value':'='},
				{'label':'Greater than', 'value':'>'},
				{'label':'Less than', 'value':'<'},
				{'label':'Greater than or Equal to', 'value':'>='},
				{'label':'Less than or Equal to', 'value':'<='}
			];		
			$scope.inputOperatorFilterOptions = $scope.inputOperatorFilterOptions1;					
		}else if($scope.selectedFilterColumn.value.type == 'BOOLEAN' || $scope.selectedFilterColumn.value.type == 'RADIO') {
        	$scope.inputOperatorFilterOptions2 = [
                {'label':'Equals to', 'value':'='},                    
                {'label':'Not equals to', 'value':'!='}
            ];   
            $scope.filterTerm = false;  
            console.log('$scope.filterTerm--',$scope.filterTerm);                    
            $scope.inputOperatorFilterOptions = $scope.inputOperatorFilterOptions2;
        }else if($scope.selectedFilterColumn.value.type == 'REFERENCE') {
        	$scope.inputOperatorFilterOptions2 = [
                {'label':'Equals to', 'value':'='},                    
                {'label':'Not equals to', 'value':'!='}
            ]; 
            var filterClause = $scope.filterClause;
            if($scope.quickSearchFilterClause != ''){
            	filterClause += ' AND ( ' + $scope.quickSearchFilterClause + ')' ;
            }                   
            //filterClause += $scope.selectedFilterColumn.detailInfo !=  undefined && $scope.selectedFilterColumn.detailInfo.WhereClause != undefined ? ' AND ' + $scope.selectedFilterColumn.detailInfo.WhereClause : '';
            //$scope.filterValue.filterClause = ' Id IN ( SELECT ' + $scope.selectedFilterColumn.value.actualField +  ' FROM ' + $scope.selectedFilterColumn.value.referenceTo + ' WHERE ' + filterClause + ' ) ';
            $scope.filterValue.filterClause = filterClause;
            $scope.filterValue.selectedFilterColumn.refFieldValue = $scope.filterValue.selectedFilterColumn.field;
            $scope.filterValue.selectedFilterColumn.referenceTo = $scope.StickyObjectName;
            $scope.inputOperatorFilterOptions = $scope.inputOperatorFilterOptions2;
            console.log('$scope.filterValue.filterClause--',$scope.filterValue.filterClause);
        }else if($scope.selectedFilterColumn.value.type == 'PICKLIST') {
        	$scope.inputOperatorFilterOptions2 = [
                {'label':'Equals to', 'value':'='},                    
                {'label':'Not equals to', 'value':'!='}
            ];  
            
            $scope.filterValue.picklistValues = selectedFilterColumn.picklistValues;
            $scope.filterValue.templateValue = $scope.filterValue.picklistValues[0];  
          //  $scope.filterTerm = $scope.filterValue.templateValue;
            $scope.inputOperatorFilterOptions = $scope.inputOperatorFilterOptions2;
        }else if($scope.selectedFilterColumn.value.type == 'MULTIPICKLIST') {
        	$scope.inputOperatorFilterOptions3 = [
                {'label':'Includes', 'value':' Includes '},
                {'label':'Excludes', 'value':' Excludes '}
            ];      
            $scope.filterValue.picklistValues = selectedFilterColumn.picklistValues; 
            $scope.filterValue.templateValue = $scope.filterValue.picklistValues[0];  
           // $scope.filterTerm = $scope.filterValue.templateValue;
            $scope.inputOperatorFilterOptions = $scope.inputOperatorFilterOptions3;
        }else if($scope.selectedFilterColumn.value.type == 'STRING'   ||  $scope.selectedFilterColumn.value.type == 'URL'
        		||  $scope.selectedFilterColumn.value.type == 'EMAIL' ||  $scope.selectedFilterColumn.value.type == 'PHONE'
        		|| $scope.selectedFilterColumn.value.type == 'COMBOBOX') {
			$scope.inputOperatorFilterOptions4 = [
				{'label':'Contains', 'value':'LIKE \'%selectedValue%\''},
				{'label':'Starts with', 'value':'LIKE \'selectedValue%\''},
				{'label':'Ends with', 'value':'LIKE \'%selectedValue\''}
			];	
			$scope.inputOperatorFilterOptions = $scope.inputOperatorFilterOptions4;			
		}
		$scope.selectedFilterOperator.value = $scope.inputOperatorFilterOptions[0]; 			
	}
	$scope.filterValue.changeHandler = function(changedVal) {  
   		$scope.filterTerm = changedVal;   		
   	}  
	$scope.filterValue.changeHandler = function(changedValId,changedValText) { 
		$scope.filterTerm = changedValId;
		$scope.filterTermText = changedValText;    			
   	} 
    $scope.filterValue.changeDateHandler = function(changedVal) {
		var date = new Date(changedVal);
		var month = (date.getMonth() + 1);
		month = month < 10 ? "0"+month : month;
		var dateStr = date.getFullYear() + '-' + month + '-' + date.getDate();
		$scope.filterTerm = dateStr;
    }
    $scope.filterValue.changeDateTimeHandler = function(changedVal) {    			
		var d = new Date()
		var n = d.getTimezoneOffset()*60*1000;		
		var d = new Date(changedVal-$scope.timeOffset-n);
		var str = d.toISOString();
		console.log('---str---',str);
		$scope.filterTerm = str;
		$scope.filterTermText = changedVal; 
    }
    
   	$scope.removeFilterPane = function(index) {
   		console.log('---$scope.filterDisplayList[index].isStickySearchCriteria---',$scope.filterDisplayList[index].isStickySearchCriteria);
   		if($scope.filterDisplayList[index].isStickySearchCriteria == true){
   			$scope.isStickySelectionChanged = true;
   		}
		var advanceFilterDisplayMap = $scope.filterDisplayList[index];
   		$scope.filterDisplayListUniquenessTracker[advanceFilterDisplayMap.column] = undefined;
   		$scope.filterDisplayList.splice(index,1);   		
   		$scope.createAdvancedFilterAndRefresh();
   	}
   	$scope.clearAllAdvFilter = function() {
   		$scope.isStickySelectionChanged = true;
   		$scope.filterDisplayList = [];
		$scope.filterDisplayListUniquenessTracker = {};
   		$scope.filterTerm = undefined;
   		$scope.selectedFilterColumn.value = $scope.columnsFilter[0];
   		$scope.advanceFilterOption($scope.selectedFilterColumn.value);
		$scope.createAdvancedFilterAndRefresh();   		
   	}
   	
    $scope.addAdvanceFilter = function() {
   		
    	if($scope.filterTerm !== '' && $scope.filterTerm != undefined) {
        	$scope.showFilterPane = true;
        	var filterValue = '';
        	var filterTermText = $scope.filterTerm;
        	var isStickySearchCriteria = false;
        	if($scope.selectedFilterColumn.value.field == $scope.StickySearchFieldApiName){
        		isStickySearchCriteria = true;
        		filterTermText = $scope.filterTermText;  					 
        		filterValue = $scope.StickySearchFieldApiName
							  + ' ' + $scope.selectedFilterOperator.value.value 
							  + '\'' + $scope.filterTermText + '\'';
				$scope.isStickySelectionChanged = true;
        	}else if($scope.selectedFilterColumn.value.type == 'STRING' || $scope.selectedFilterColumn.value.type == 'COMBOBOX' || $scope.selectedFilterColumn.value.type == 'PHONE'|| $scope.selectedFilterColumn.value.type == 'EMAIL'){
        		filterValue = $scope.selectedFilterColumn.value.field 
        					  + ' ' + $scope.selectedFilterOperator.value.value.replace('selectedValue',$scope.filterTerm);         					 
        	}else if($scope.selectedFilterColumn.value.type == 'PICKLIST'){
        		filterValue = $scope.selectedFilterColumn.value.field 
        					  + ' ' + $scope.selectedFilterOperator.value.value 
        					  + ' \'' + $scope.filterTerm + '\'';    					 
        	}else if($scope.selectedFilterColumn.value.type == 'MULTIPICKLIST'){
        		
        		console.log('filterTerm--34324-',$scope.filterTerm);
        		filterValue = $scope.selectedFilterColumn.value.field 
        					  + ' ' + $scope.selectedFilterOperator.value.value;
				filterValue += '('; 
				if($scope.filterTerm.constructor === Array){
					if($scope.filterTerm.length > 0){
					  	for(var i = 0 ; i < $scope.filterTerm.length - 1 ; i++){
					  		filterValue += '\'' + $scope.filterTerm[i] + '\','; 
					  	}
				  	}
				  	filterValue += '\'' + $scope.filterTerm[i] + '\'';
			  	}else{
			  		filterValue += '\'' + $scope.filterTerm + '\'';
			  	}
			  	filterValue += ')';
        	}else if($scope.selectedFilterColumn.value.type == 'REFERENCE'){
        		filterTermText = $scope.filterTermText;  					 
        		if($scope.selectedFilterColumn.value.actualField.includes(".")){
        		    filterValue = $scope.selectedFilterColumn.value.actualField 
							  + ' ' + $scope.selectedFilterOperator.value.value 
							  + '\'' + $scope.filterTermText + '\'';
        		}
        		else{
        		filterValue = $scope.selectedFilterColumn.value.actualField 
							  + ' ' + $scope.selectedFilterOperator.value.value 
							  + '\'' + $scope.filterTerm + '\'';
        		}					 	
        	}else if($scope.selectedFilterColumn.value.type == 'BOOLEAN'){        		
        		console.log('---filterTermText---',filterTermText);  					 
        		filterValue = $scope.selectedFilterColumn.value.field 
							  + ' ' + $scope.selectedFilterOperator.value.value 
							  + $scope.filterTerm ;
        	}else if($scope.selectedFilterColumn.value.type == 'DATETIME'){
        		filterTermText = $scope.filterTermText; 
        		$scope.newDate = new Date(filterTermText);
        		// This code add for maintain old date value ...
        		$scope.newDisplayDate = new Date(filterTermText);
        		
        		// This Code Add for Advance Filter DateTime Break for Greater Than.
        		if($scope.selectedFilterOperator.value.value == '>'){
        		     $scope.newDate.setTime($scope.newDate.getTime() + 1 *60000);
        		     console.log('---filterTermText New--->',$scope.newDate.getTime());
        		}
        		
        		// This Code Add for Advance Filter DateTime Break for Less Than.
        		if($scope.selectedFilterOperator.value.value == '<'){
        		    $scope.newDate.setTime($scope.newDate.getTime() - 1 *60000);
        		     console.log('---filterTermText New--->',$scope.newDate.getTime()); 
        		}
        		
        		if($scope.selectedFilterOperator.value.value == '<='){
        		    $scope.newDate.setTime($scope.newDate.getTime() + 1 *60000);
        		     console.log('---filterTermText New--->',$scope.newDate.getTime()); 
        		}
        		
        		console.log('---filterTermText New--->',$scope.newDate.getTime());
        		//filterTermText = $filter('date')($scope.newDate, 'MM/dd/yyyy h:mm a');
        		$scope.filterTerm = formatLocalDate($scope.newDate);
        		
        		
        		console.log('---filterTermText New--->',filterTermText);
        		filterValue = $scope.selectedFilterColumn.value.field 
				  + ' ' + $scope.selectedFilterOperator.value.value 
				  + ' ' + $scope.filterTerm;
				  
				// This Code is for display date term with orignal value even its update for greater than or less than
        	    filterTermText = $filter('date')($scope.newDisplayDate, 'MM/dd/yyyy h:mm a');
        	}else if($scope.selectedFilterColumn.value.type == 'DATE'){
        		$scope.newDate =new Date(filterTermText);
        		filterTermText = $filter('date')($scope.newDate, 'MM/dd/yyyy');
        		filterValue = $scope.selectedFilterColumn.value.field 
				  + ' ' + $scope.selectedFilterOperator.value.value 
				  + ' ' + $filter('date')($scope.newDate, 'yyyy-MM-dd');
				 // + ' ' + $scope.filterTerm;
				  
        	}
        	else if($scope.selectedFilterColumn.value.type == 'CURRENCY' || $scope.selectedFilterColumn.value.type == 'DOUBLE'){
        		$scope.filterTerm=$scope.filterTerm.replace(/[^0-9. ]/g, "");
        		filterValue = $scope.selectedFilterColumn.value.field 
				  + ' ' + $scope.selectedFilterOperator.value.value 
				  + ' ' + $scope.filterTerm;
        		console.log('$scope.filterTerm------',$scope.filterTerm);
				  
        	}else{
        		filterValue = $scope.selectedFilterColumn.value.field 
        					  + ' ' + $scope.selectedFilterOperator.value.value 
        					  + ' ' + $scope.filterTerm;
        	}
        	var operator = angular.copy($scope.selectedFilterOperator);
        	$scope.advanceFilterDisplayMap = {
        										"isStickySearchCriteria":isStickySearchCriteria,
        										"column":$scope.selectedFilterColumn.value,
        										"operator":operator ,        										
        										"filterTerm":$scope.filterTerm,
        										"filterTermText":filterTermText,
        										"filterValue": filterValue,
        										"filterLabel": $scope.selectedFilterColumn.value.displayName 
        													+ ' ' + $scope.selectedFilterOperator.value.label 
        													+ ' ' + $scope.filterTerm
											};
        	if($scope.filterDisplayListUniquenessTracker[$scope.advanceFilterDisplayMap.column] != $scope.advanceFilterDisplayMap.filterLabel){
	        	$scope.filterDisplayList.push($scope.advanceFilterDisplayMap); 
	        	$scope.filterDisplayListUniquenessTracker[$scope.advanceFilterDisplayMap.column] = $scope.advanceFilterDisplayMap.filterLabel; 
	        	$scope.createAdvancedFilterAndRefresh();
        	} 
    	}
    	console.log('$scope.filterDisplayList: ',$scope.filterDisplayList);
    	
    } 

    	
    $scope.createAdvanceFilterString = function(){
    	var filterString = '';
		$scope.advFilterClause = '';
		var columnTracker = {};
		var stickySearchJSON = [];
		var stickySearchFilterClause = '';
		for(var i = 0 ; i < $scope.filterDisplayList.length ; i++){
			console.log('===columnTracker==1==',columnTracker);	
			console.log('===$scope.filterDisplayList[i]==',$scope.filterDisplayList[i]['column']);	
			if(columnTracker[$scope.filterDisplayList[i]['column'].actualField] == undefined){
				columnTracker[$scope.filterDisplayList[i]['column'].actualField] = [];
			}
			var columnFiltersArray = columnTracker[$scope.filterDisplayList[i]['column'].actualField];
			columnFiltersArray.push($scope.filterDisplayList[i]);
			columnTracker[$scope.filterDisplayList[i]['column'].actualField] = columnFiltersArray;
			if($scope.filterDisplayList[i]['isStickySearchCriteria'] == true){
				stickySearchJSON.push($scope.filterDisplayList[i]);
				stickySearchFilterClause += $scope.StickySearchFieldApiName + $scope.filterDisplayList[i]['operator'].value.value + ' \'' + $scope.filterDisplayList[i]['filterTermText'] + '\' OR ';
			}			
		}
		if(stickySearchFilterClause != ''){
			stickySearchFilterClause = stickySearchFilterClause.substring(0,stickySearchFilterClause.length - 4);
			stickySearchFilterClause = '('+stickySearchFilterClause+')';
			$scope.StickySearchCriteria = stickySearchFilterClause;
			$scope.stickySearchJSON = angular.toJson(stickySearchJSON);
		}else{
			$scope.StickySearchCriteria = '';
			$scope.stickySearchJSON = '';
		}
		console.log('===$scope.StickySearchCriteria==2==',$scope.StickySearchCriteria);	
		console.log('===$scope.stickySearchJSON==',$scope.stickySearchJSON);	
		console.log('===columnTracker==2==',columnTracker);	
		for(column in columnTracker){
			console.log('===column==2==',column);	
			var columnFilterString = '(';
			var columnFiltersArray = columnTracker[column];
			console.log('===columnFiltersArray==2==',columnFiltersArray);	
			for(var i = 0 ; i < columnFiltersArray.length ; i++){
				columnFilterString += columnFiltersArray[i]['filterValue'] + ' OR ';	
			}
			columnFilterString = columnFilterString.substring(0,columnFilterString.length-4);
			columnFilterString += ')';
			console.log('===columnFilterString====',columnFilterString);	
			filterString += columnFilterString + ' AND ';
		}
		filterString = filterString.substring(0,filterString.length-4);
		console.log('===filterString====',filterString);

		$scope.advFilterClause = filterString;
    }
    	
    $scope.createAdvancedFilterAndRefresh = function(){    				
		$scope.createAdvanceFilterString();
		console.log('$scope.advFilterClause---',$scope.advFilterClause);
		$scope.newFilterClause = $scope.filterClause;
		console.log('$scope.newFilterClause---',$scope.newFilterClause);
		var bitOperator = $scope.newFilterClause == '' ? '' : ' AND ';
		if($scope.quickSearchFilterClause != ''){			
			$scope.newFilterClause = $scope.newFilterClause + bitOperator + ' (' + $scope.quickSearchFilterClause + ')';	
		}
		bitOperator = $scope.newFilterClause == '' ? '' : ' AND ';
		if($scope.advFilterClause != ''){
			$scope.newFilterClause = $scope.newFilterClause + bitOperator + ' (' + $scope.advFilterClause + ')';		
		} 
		console.log('$scope.newFilterClause---',$scope.newFilterClause);
		$scope.pageNumber = 1;	
		$scope.getPageRecords();
    }
    
    $scope.hiddenColumnMap = {};
    $scope.hideColumnFunction = function(result) { 
    	for(var i =0; i < $scope.FlexTableMetaData.ColumnsNameList.length; i++) { 
    		var col = $scope.FlexTableMetaData.ColumnsNameList[i];  
    		var count = 0; 
    		if(result.DataTableInfo.RecordsList != undefined ){   		
	    		for(var j =0 ; j < result.DataTableInfo.RecordsList.length ; j++){	    			
	    			var hiddenCondition = $scope.getHide(result.DataTableInfo.RecordsList[j],col,angular.fromJson($scope.FlexTableMetaData.DataTableInfoMap.HideColumnsJSON)); 
	    			if(hiddenCondition == 'true') {	
	    				count= count +1;	    				    					    					    						
	    			}	    			      			
	    		}
    		}  
    		if(result.DataTableInfo.RecordsList != undefined && result.DataTableInfo.RecordsList.length > 0 && result.DataTableInfo.RecordsList.length == count){    		
					$scope.hiddenColumnMap[col] = true;
			}else{
				$scope.hiddenColumnMap[col] = false; 
			} 
		}
    }
    
	$scope.getHide = function(row, col, hiddenColumn) {	
		if (row != undefined) {			
			var conditionsArray = hiddenColumn;
			var isHide = false;
			if (conditionsArray != undefined) {
				for (var i = 0; i < conditionsArray.length; i++) {
					if (conditionsArray[i].operator == '=') {
							
						if (row[conditionsArray[i].field.trim()] == conditionsArray[i].value && col == hiddenColumn[i].column) {											
							isHide = true;  
							if ($scope.hiddenColumns == undefined) {
								$scope.hiddenColumns = {};
							}
							$scope.hiddenColumns[col] = $scope.hiddenColumns[col] == undefined ? 0 : $scope.hiddenColumns[col]+1;                                								
							break;                                      
						}
					}
					else if (conditionsArray[i].operator == '!=') {
						if (row[conditionsArray[i].field] != conditionsArray[i].value && col == hiddenColumn[i].column) {
							isHide = true; 
							if ($scope.hiddenColumns == undefined) {
								$scope.hiddenColumns = {};
							}
							$scope.hiddenColumns[col] = $scope.hiddenColumns[col] == undefined ? 0 : $scope.hiddenColumns[col]+1;                                 								
							break;                                         
						}
					}                                
				}		
				if (isHide == false) {
					return 'false';
				}					
				return 'true';
			}
		}                                    
		return 'false'; 
	};
	
	$scope.createStickySearchPills = function(StickySearchJSON){
		console.log('===StickySearchJSON==1=',StickySearchJSON);
		var stickyFilterClauses = angular.fromJson(StickySearchJSON);
		console.log('===stickyFilterClauses==1=',stickyFilterClauses);
		$scope.filterDisplayList = stickyFilterClauses;
		$scope.showFilterPane = true;
		$scope.showCollapsed = false;
		$scope.createAdvanceFilterString();			
	}
	$scope.paintFlexTable = function(flexTableResult){
		$scope.originalPageSize = flexTableResult.ConfigInfo.DefaultPageSize;
		console.log('++$scope.originalPageSize++',$scope.originalPageSize);
		$scope.noRecords = false;
		$scope.keyValueMap = flexTableResult.KeyValueMap;
		$scope.flexTableHeader = flexTableResult.FlexTableHeader;
		$scope.objectMetadata = flexTableResult.ObjectMetaData;
		$scope.tableConfigInfo = flexTableResult.ConfigInfo;
		
		$scope.dataTableInfoFC = flexTableResult.DataTableInfo.FilterClause;
		$scope.dataTableInfo = flexTableResult.DataTableInfo;
		$scope.flexTableHeader = $scope.tableConfigInfo.Header;
		$scope.dataTableInfoMap =  flexTableResult.DataTableInfoMap;
		console.log('---scope.StickySearchLastSearchTerm---',$scope.tableConfigInfo);
		if($scope.dataTableInfoMap != undefined){			
			$scope.StickySearchFieldApiName = flexTableResult.DataTableInfoMap.StickySearchFieldApiName;
			$scope.StickySearchLastSearchTerm = flexTableResult.DataTableInfoMap.StickySearchLastSearchTerm;
			console.log('---scope.StickySearchLastSearchTerm---',$scope.StickySearchLastSearchTerm);
			$scope.StickySearchJSON = flexTableResult.DataTableInfoMap.StickySearchJSON;
			console.log('---scope.StickySearchJSON---',$scope.StickySearchJSON);
			if($scope.StickySearchJSON != undefined && $scope.StickySearchJSON != ''){
				$scope.createStickySearchPills($scope.StickySearchJSON);
			}
			$scope.ConfigFilterClause = flexTableResult.DataTableInfoMap.ConfigFilterClause;
						console.log('---$scope.ConfigFilterClause---',$scope.ConfigFilterClause);
			
			$scope.FlexTableFilterListViewValues = flexTableResult.DataTableInfoMap.LabelToFilterClause;
			$scope.StickySearchPlaceHolderText = flexTableResult.DataTableInfoMap.StickySearchPlaceHolderText;                             
			$scope.StickyObjectName = flexTableResult.DataTableInfoMap.SObjectName;			
		}                
		$scope.FlexTableHistoryList = flexTableResult.ChildRelationShips;
		$scope.FlexTableHistoryRelatedList = flexTableResult.ChildRelationShipList;
		$scope.DefaultMap = flexTableResult.DefaultMap;
		$scope.NoChildPresent= flexTableResult.NoChildPresent;
		$scope.FlexTableMetaData = flexTableResult;
		
		//if($scope.dataTableInfoMap != undefined) {	
			$scope.hideColumnIfDataIsStar = $scope.hideColumnFunction(flexTableResult);
		//}
		if($scope.NoChildPresent == 'false' || $scope.NoChildPresent == false){
			for (var key in $scope.DefaultMap ) {				
				$scope.data.historyObj = key;
				break;
			}                   
		}
		
		var activeCount = 0;
		$scope.ShowFilterViewList = false;
		if($scope.FlexTableFilterListViewValues != undefined){
			for(var i=0;i<$scope.FlexTableFilterListViewValues.length;i++){
				if($scope.FlexTableFilterListViewValues[i].isActive == true){
					activeCount++;
				}                        
			}
			if(activeCount == 1){				
				$scope.flexTableHeader = $scope.FlexTableFilterListViewValues[i-1].label;
			}else if(activeCount > 1){
				$scope.ShowFilterViewList = true;  
				$scope.updatedHeader = $scope.updateFlexHeader();
			}                    			                                    
		}                
		
		$scope.FlexTableMetaData = flexTableResult;
		
		$scope.FlexTableRecordId = flexTableResult.ConfigInfo.FlexTableRecordId;   
		$scope.FlexKeyValueMap = flexTableResult.KeyValueMap;             
		if($scope.StickySearchFieldApiName){
			$scope.showStickySearchTextBox = true;
		}else{
			$scope.showStickySearchTextBox = false;
		}                
		/* 1. Create the action buttons, links, etc. information */
		$scope.actionInfo = flexTableResult.ActionInfo;
		$scope.topActionItems = [];
		$scope.rowActionItems = [];
		$scope.headerButtonLinkCount = 0;
		$scope.offset = flexTableResult.Offset;

	   if(flexTableResult.DataTableInfoMap== undefined){
		   $scope.hideRowLevelAction = true;
	   }else{
		   $scope.hideRowLevelAction = ( flexTableResult.DataTableInfoMap.RowLevelActionForDisabled == undefined || flexTableResult.DataTableInfoMap.RowLevelActionForDisabled == '' || flexTableResult.DataTableInfoMap.RowLevelActionForDisabled == 'Show') ? false : true;
	   }
		
		$scope.userOffset;
		

		for(a in $scope.actionInfo) {
			$scope.addAction = true;
			if($scope.actionInfo[a].StandardAction == 'New' && $scope.objectMetadata.IsCreateable != 'true'){
				$scope.addAction = false;
			}else if($scope.actionInfo[a].StandardAction == 'Edit' && $scope.objectMetadata.IsUpdateable != 'true'){
				$scope.addAction = false;
			}else if($scope.actionInfo[a].StandardAction == 'Delete' && $scope.objectMetadata.IsDeletable != 'true'){
				$scope.addAction = false;
			}
			if($scope.addAction == true){
				var name = a;
				
				if($scope.actionInfo[a].Location == 'Top'){
					if($scope.actionInfo[a].HeaderActionDisplayType == 'Button' || $scope.actionInfo[a].HeaderActionDisplayType == 'Link'){
						$scope.headerButtonLinkCount = $scope.headerButtonLinkCount + 1;
					}
					$scope.topActionItems.push({"name":name,"refreshBehaviour":$scope.actionInfo[a].RefreshBehavior,"confirmationMessage":$scope.actionInfo[a].ConfirmationMessage,"showConfirmationBox":$scope.actionInfo[a].ShowConfirmationBox,"isModalDialog":$scope.actionInfo[a].IsModalDialog,"standardAction":$scope.actionInfo[a].StandardAction,"actionURL":$scope.actionInfo[a].ActionURL,"actionBehavior":$scope.actionInfo[a].ActionBehavior,"actionClass":$scope.actionInfo[a].ActionClass,"sequence":$scope.actionInfo[a].Sequence,"height":$scope.actionInfo[a].Height,"width":$scope.actionInfo[a].Width,"icon":$scope.actionInfo[a].Icon,"HeaderActionDisplayType":$scope.actionInfo[a].HeaderActionDisplayType,"ButtonHelpText":$scope.actionInfo[a].ButtonHelpText,"toolTip":a,"dataTableActionObj":$scope.actionInfo[a].DataTableActionObj,"hideDecisionField":$scope.actionInfo[a].HideDecisionField,"hideAction" :$scope.actionInfo[a].hideAction,"HideDecisionForTopButtons":$scope.actionInfo[a].HideDecisionForTopButtons,"modalTitle":$scope.actionInfo[a].ModalTitle,"hideInSearch" :$scope.actionInfo[a].hideInSearch});
				}else if($scope.actionInfo[a].Location == 'Row'){
					$scope.rowActionItems.push({"name":name,"refreshBehaviour":$scope.actionInfo[a].RefreshBehavior,"confirmationMessage":$scope.actionInfo[a].ConfirmationMessage,"showConfirmationBox":$scope.actionInfo[a].ShowConfirmationBox,"isModalDialog":$scope.actionInfo[a].IsModalDialog,"standardAction":$scope.actionInfo[a].StandardAction,"actionURL":$scope.actionInfo[a].ActionURL,"actionBehavior":$scope.actionInfo[a].ActionBehavior,"actionClass":$scope.actionInfo[a].ActionClass,"sequence":$scope.actionInfo[a].Sequence,"height":$scope.actionInfo[a].Height,"width":$scope.actionInfo[a].Width,"icon":$scope.actionInfo[a].Icon,"dataTableActionObj":$scope.actionInfo[a].DataTableActionObj,"hideDecisionField":$scope.actionInfo[a].HideDecisionField,"hideAction" :$scope.actionInfo[a].hideAction,"modalTitle":$scope.actionInfo[a].ModalTitle,"hideOperator":$scope.actionInfo[a].hideOperator,"hideInSearch" :$scope.actionInfo[a].hideInSearch,"ButtonHelpText":$scope.actionInfo[a].ButtonHelpText});
				}
			}
		}
		
		/* 2. Create the column information */
		/* Special case handling for Task object */
		$scope.objectName = flexTableResult.DataTableInfo.ObjectName;

		var InitialFilterClause = flexTableResult.IntialFilterClause;		
		if( flexTableResult.IntialFilterClause != undefined && flexTableResult.IntialFilterClause != '' ) {
			$scope.filterClause = flexTableResult.IntialFilterClause;
			//angular.copy($scope.filterClause, $scope.newFilterClause);
			if( $scope.newFilterClause == undefined || $scope.newFilterClause == '' || $scope.newFilterClause == null ) {
				$scope.newFilterClause = ''+ $scope.filterClause;				
			} /*else {
				$scope.newFilterClause = $scope.newFilterClause +' and '+ $scope.filterClause;				
			}*/
		}
	  
		$scope.fieldsMap = flexTableResult.FieldMetadata;
		$scope.renderBtnPDF = flexTableResult.renderBtnForPDF;
		$scope.renderBtnCSV = flexTableResult.renderBtnForCSV;
		$scope.fieldsColumnMap = flexTableResult.FieldsColumnMap;
		$scope.columnsNameList = flexTableResult.ColumnsNameList;
		for(var i=0; i < $scope.columnsNameList.length;i++) {
			var f = $scope.columnsNameList[i];
			var showFilter = true;

			// Pankaj : Need to discuss			
			var fieldDataType;
			var displayName;
			var columnWidth='';
			var isFilterable;
			if(flexTableResult.FieldMetadata[f].Type == 'PICKLIST' || flexTableResult.FieldMetadata[f].Type == 'MULTIPICKLIST'){
				$scope.pickListMap[f] = flexTableResult.FieldMetadata[f].PicklistValues;
				$scope.pickListValueLabelMap[f] = flexTableResult.FieldMetadata[f].FieldPicklistValueLabelMap;
				console.log('new $scope.pickListValueLabelMap[f]-->',$scope.pickListValueLabelMap[f]);
				console.log('pickList Map New-->',$scope.pickListMap[f]);
			}
			var refFieldPath = 'row';
			var refFieldValue ;
			console.log('===> type   ',flexTableResult.FieldMetadata[f].Type);
			if(flexTableResult.FieldMetadata[f].Type == 'REFERENCE' && f.indexOf('.') != -1){
				var refField = f.split('.');				
				for(var j=0;j < refField.length - 1 ; j++){
					refFieldPath += '[\''+refField[j]+'\']'
				}
				refFieldValue = refField[j];				
				if(refFieldValue.toLowerCase() == 'name'){
					fieldDataType = 'REFERENCE';
					displayName = flexTableResult.FieldMetadata[f].Label;
					if(j > 1){
						displayName = flexTableResult.FieldMetadata[f].ReferenceFieldInfo.Label;
					}
					isFilterable = flexTableResult.FieldMetadata[f].ReferenceFieldInfo.IsFilterable;
					console.log('===> flexTableResult.FieldMetadata[f].ReferenceFieldInfo.IsFilterable   ',flexTableResult.FieldMetadata[f].ReferenceFieldInfo.IsFilterable);
					console.log('===> if   ',isFilterable); 
				}else{
					refFieldPath += '[\''+refFieldValue+'\']';
					fieldDataType = flexTableResult.FieldMetadata[f].ReferenceFieldInfo.Type;
					displayName = flexTableResult.FieldMetadata[f].ReferenceFieldInfo.Label;
					isFilterable = flexTableResult.FieldMetadata[f].ReferenceFieldInfo.IsFilterable;
					console.log('===> flexTableResult.FieldMetadata[f].ReferenceFieldInfo.IsFilterable   ',flexTableResult.FieldMetadata[f].ReferenceFieldInfo.IsFilterable);
					console.log('===> else   ',isFilterable);
				}
				/*long text area fields not filterable in query call*/
				if(flexTableResult.FieldMetadata[f].ReferenceFieldInfo.IsFilterable == false){
					console.log('===> in if'+flexTableResult.FieldMetadata[f].ReferenceFieldInfo.IsFilterable);
					$scope.quickSearchHelpText += displayName + ',';
				}

			}else{
				refFieldPath += '[\''+f+'\']';
				refFieldValue = f;
				fieldDataType = flexTableResult.FieldMetadata[f].Type;
				displayName = flexTableResult.FieldMetadata[f].Label;
				isFilterable = flexTableResult.FieldMetadata[f].IsFilterable;
			}

			if( flexTableResult.FieldMetadata[f].ColumnWidth != undefined && flexTableResult.FieldMetadata[f].ColumnWidth != '' && flexTableResult.FieldMetadata[f].ColumnWidth != null && flexTableResult.FieldMetadata[f].ColumnWidth != 'null' ) {
				columnWidth = flexTableResult.FieldMetadata[f].ColumnWidth + "%";
			}
			
			if(flexTableResult.FieldMetadata[f].IsFilterable  == false){
				console.log('===> in if filterable '+flexTableResult.FieldMetadata[f].IsFilterable);
				$scope.quickSearchHelpText += displayName + ',';
			}
			
			//$scope.columns.push({"field": f,"refField": refFieldPath ,"refFieldValue":refFieldValue,"displayName":displayName,"width":columnWidth,"showFilter":showFilter,"type":fieldDataType,"term1":'',"term2":'',"isFilterable":flexTableResult.FieldMetadata[f].IsFilterable,"isRefFilterable":isRefFilterable});
			$scope.columns.push({"field": f,"refField": refFieldPath ,"refFieldValue":refFieldValue,"displayName":displayName,"width":columnWidth,"showFilter":showFilter,"type":fieldDataType,"term1":'',"term2":'',"isFilterable":Boolean(isFilterable)});
			console.log('===> column '+JSON.stringify($scope.columns));
			if(fieldDataType != 'ID' && fieldDataType != 'TEXTAREA' ) {
				var referenceTo  = flexTableResult.FieldMetadata[f].ReferenceTo;
				referenceTo = referenceTo == undefined ? flexTableResult.DataTableInfo.ObjectName : referenceTo;
				if(flexTableResult.FieldMetadata[f].ReferenceFieldInfo == undefined){
					$scope.columnsFilter.push({"actualField": $scope.fieldsColumnMap[f],"field": f,"refField": refFieldPath ,"refFieldValue":refFieldValue,"displayName":displayName,"width":columnWidth,"showFilter":showFilter,"type":fieldDataType,"term1":'',"term2":'',"isFilterable":flexTableResult.FieldMetadata[f].IsFilterable,"referenceTo":referenceTo, "picklistValues":flexTableResult.FieldMetadata[f].PicklistValues,"detailInfo":flexTableResult.FieldMetadata['dataTableDetailInfo'][referenceTo]});
				}else{
					console.log('====flexTableResult.FieldMetadata[f].ReferenceFieldInfor===',flexTableResult.FieldMetadata[f].ReferenceFieldInfo.PicklistValues);
					$scope.columnsFilter.push({"actualField": $scope.fieldsColumnMap[f],"field": f,"refField": refFieldPath ,"refFieldValue":refFieldValue,"displayName":displayName,"width":columnWidth,"showFilter":showFilter,"type":fieldDataType,"term1":'',"term2":'',"isFilterable":flexTableResult.FieldMetadata[f].IsFilterable,"referenceTo":referenceTo, "picklistValues":flexTableResult.FieldMetadata[f].ReferenceFieldInfo.PicklistValues,"detailInfo":flexTableResult.FieldMetadata['dataTableDetailInfo'][referenceTo]});	
				}
				if($scope.StickySearchFieldApiName != undefined && $scope.StickySearchFieldApiName == f){
					$scope.stickyColumn = displayName;
				}
				$scope.selectedFilterColumn.value = $scope.columnsFilter[0];
				console.log('====$scope.columnsFilter===',$scope.columnsFilter);
				$scope.advanceFilterOption($scope.selectedFilterColumn.value);								
			}
		}
		console.log('===> helptext '+$scope.quickSearchHelpText)
		$scope.quickSearchHelpText = $scope.quickSearchHelpText.substring(0,$scope.quickSearchHelpText.length-1)
		$scope.helpText = 'Quick Search is not supported for following columns : '+ $scope.quickSearchHelpText;  
		console.log('===> helptext '+$scope.quickSearchHelpText)
		/* 3. Create the table data information */
		if($scope.flexTable_isPreview != 'true'){
			$scope.tableData = flexTableResult.DataTableInfo.RecordsList;
		}
		if($scope.tableData != undefined && $scope.tableData.length == 0){
			$scope.noRecords = true;
		}

		/* 4. Create the table configuration information */


		$scope.pageSizeArray = flexTableResult.ConfigInfo.PageSizes.split(';');

		/* 5. Create the table configuration information required between server calls*/
		$scope.queryColumns = flexTableResult.DataTableInfo.QueryColumns;
		$scope.hideDecisionFields = flexTableResult.DataTableInfo.HideDecisionFields;
		$scope.resultSize = flexTableResult.DataTableInfo.ResultSize;
		for(i = 0;i <  $scope.pageSizeArray.length; i++){
			$scope.pageSizes.push( $scope.pageSizeArray[i]);
		}
		if(flexTableResult.DataTableInfo.ResultSize >= flexTableResult.ConfigInfo.DefaultPageSize && flexTableResult.DataTableInfo.ResultSize <= flexTableResult.ConfigInfo.MaxRecordsCount){
			$scope.pageSizes.push('All');
		}		
		$scope.totalRecordsCount = flexTableResult.DataTableInfo.ResultSize;
		$scope.totalRecords = 'Total Records: '+ flexTableResult.DataTableInfo.ResultSize;
		$scope.pageNumber = flexTableResult.DataTableInfo.PageNumber;
		$scope.totalPages = flexTableResult.DataTableInfo.TotalPages;
		if(flexTableResult.DataTableInfo.PageSize != undefined){
			if ($scope.pageSizes.indexOf(flexTableResult.DataTableInfo.PageSize.toString()) > -1) {
                 $scope.defultValPageSize = '';
                 $scope.pageSize = flexTableResult.DataTableInfo.PageSize;
	        } else {
	                 $scope.defultValPageSize = 'All';
	                $scope.pageSize = flexTableResult.DataTableInfo.PageSize;
	        }	
		}
		$scope.hasNext = flexTableResult.DataTableInfo.HasNext;
		$scope.hasPrevious = flexTableResult.DataTableInfo.HasPrevious;
		$scope.pageInfo = 'Page ' + $scope.pageNumber + ' of ' +  $scope.totalPages;
		$scope.sortFieldName =  flexTableResult.DataTableInfo.SortColumn;
		if($scope.sortFieldName == undefined){
			$scope.sortFieldName = '';
		}
		$scope.sortDirection =  flexTableResult.DataTableInfo.SortDir;
		if($scope.sortDirection == undefined){
			$scope.sortDirection = 'ASC';
		}
		/* 6. Set the loading to false */
		$scope.setLoading(false);
		
		/* 7.Column Hide*/
		if($scope.dataTableInfoMap != undefined) {	
			$scope.hiddenColumn = angular.fromJson(flexTableResult.DataTableInfoMap.HideColumnsJSON);		
			$scope.hiddencolumns = [];
			$scope.massEditableGridConfigJSON = angular.fromJson(flexTableResult.ConfigInfo.MassEditableGridConfigJSON);
		}
		/*8.Flex Table Header for 508*/		
			
		if(typeof skipNavMap !== 'undefined'){
			if(skipNavMap[$scope.flexTable_dataTableConfigName+'flexTable'] == undefined){											
				$timeout( function(){ $scope.getNavLinks2(); }, 2000);
				$timeout( function(){ $scope.getNavLinks_InnerHtml(); }, 3000);
			}
		}
		
	};
	$scope.getNavLinks2 = function(){
		j$( '#skipNav' ).empty();
		j$('.skipNavSectionItem2').each(function() {
	        if (j$(this).text() != '') {
	            var hrefId = j$(this).attr('id');
	            var currentItem = j$(this).attr('name')		            
	            
	            if(currentItem.indexOf('Flex Table') != -1){
					j$('#skipNav').append('<a id="'+hrefId+'SkipLink" class="skip-main" href="#'+j$(this).attr('id')+'FlexTable">Skip to  '+j$(this).text()+'</a>');	            	            		   
				}else{
	            	j$('#skipNav').append('<a id="'+hrefId+'SkipLink" class="skip-main" href="#'+j$(this).attr('id')+'">Skip to '+j$(this).text()+'</a>');
	            }	        	       	            	                       	            	            
	        }	        	       
	    });
		
	};
	$scope.getNavLinks_InnerHtml = function(){
		if(document.getElementById($scope.flexTable_dataTableConfigName+'SkipLink') != undefined){
			document.getElementById($scope.flexTable_dataTableConfigName+'SkipLink').innerHTML = 'Skip to ' +$scope.flexTableHeader;			
		}
		if(document.getElementById($scope.flexTableId+'SkipLink') != undefined){
			document.getElementById($scope.flexTableId+'SkipLink').innerHTML = 'Skip to ' +$scope.flexTableHeader;		
		}
		if(document.getElementById('tmpcase1SkipLink') != undefined && document.getElementById('MessagesHomeSkipLink') != undefined){
			document.getElementById('tmpcase1SkipLink').innerHTML = 'Skip to My WorkSpace - Cases';
			document.getElementById('MessagesHomeSkipLink').innerHTML = 'Skip to: My WorkSpace - Message';
		}
	};
	
	$scope.getPageRecords = function(){
		$scope.isRefresh = true;
		if($scope.pageNumber == 0){
			$scope.pageNumber = 1;
		}   
		
		var paramMap = {};
		paramMap.queryColumns = $scope.queryColumns;
		paramMap.hideDecisionFields = $scope.hideDecisionFields;
		
		paramMap.pageNumber = $scope.pageNumber;		

		/*for(i = 0;i < $scope.pageSizes.length; i++){
            if($scope.pageSize != $scope.pageSizes[i] && ){ 
				//console.log('pageSize--->'+$scope.pageSize);
				//$scope.pagesizecheck = $scope.pageSize;
				$scope.defultValPageSize = 'All';// $scope.pagesizecheck; //$scope.pagesizecheck; //pagesizecheck;
            } 
		}*/
		if(j$.inArray($scope.pageSize.toString(), $scope.pageSizes) == -1)
			$scope.defultValPageSize = 'All';
		else
			$scope.defultValPageSize = $scope.pageSize;
			
		paramMap.pageSize = $scope.pageSize;
		 
		paramMap.sortFieldName = $scope.sortFieldName;
		paramMap.sortDirection = $scope.sortDirection;
		paramMap.searchTerm = $scope.searchTerm;
		if($scope.isHistory == true){			
			paramMap.objectName = $scope.objectName;
			paramMap.isHistory = true;
			paramMap.newFilterClause = $scope.dataTableInfoFC;
		}else{
			paramMap.newFilterClause = $scope.newFilterClause;
			paramMap.objectName = $scope.objectName;
			paramMap.isHistory = false;
		}
		paramMap.isSOSL = $scope.isSOSL;
		paramMap.stickySearchTerm = $scope.StickyUserSelection;
		paramMap.flexTableId = $scope.FlexTableRecordId;
		paramMap.isSelectionChagned = $scope.isStickySelectionChanged;      
		paramMap.stickySearchCriteria = $scope.StickySearchCriteria; 
		paramMap.stickySearchJSON = $scope.stickySearchJSON; 
		paramMap.isFilterCriteriaChanged = $scope.isFilterCriteriaChanged;     
		paramMap.updatedFlexHeader = $scope.updatedHeader;   
		paramMap.flexKeyValueMap = angular.toJson($scope.FlexKeyValueMap);
		console.log('---------paramMap----------',paramMap);                         		   
		var deferred = $q.defer();
		Visualforce.remoting.Manager.invokeAction(
			_RemotingFlexTableActions.UpdateFlexTableWithStickySearch,
			paramMap,
			function(flexTableResult, event){
				if (event.status) {
					resetSession();
					$scope.$apply(function () {
						deferred.resolve(flexTableResult);
						$scope.tableData = flexTableResult.RecordsList;
						$scope.noRecords = false;
						if($scope.tableData.length == 0){
							$scope.noRecords = true;
						}

						$scope.queryColumns = flexTableResult.QueryColumns;
						$scope.hideDecisionFields = flexTableResult.HideDecisionFields;
						$scope.objectName = flexTableResult.ObjectName;
						$scope.resultSize = flexTableResult.ResultSize;
						$scope.totalRecords = 'Total Records: '+ flexTableResult.ResultSize;
						$scope.pageNumber = flexTableResult.PageNumber;
						$scope.totalPages = flexTableResult.TotalPages;
						$scope.pageSize = flexTableResult.PageSize;
						$scope.hasNext = flexTableResult.HasNext;
						$scope.hasPrevious = flexTableResult.HasPrevious;
						$scope.pageInfo = 'Page ' + $scope.pageNumber + ' of ' +  $scope.totalPages;
						//$scope.setLoading(false);
						$scope.setSelectAllCheckBox();
						$scope.windowURL = '' ;
						$scope.isRefresh = false;
					});
				}
				$scope.isSOSL = false;
				$scope.isStickySelectionChanged = false;
				$scope.isFilterCriteriaChanged = false;
				hideLoadingPopUp();
			 
				adjustToggleBarHeightUI();
			},
			{ buffer: false, escape: false, timeout: 30000 }
		);
		return deferred.promise;
	};
	
	$scope.showTooltip= function(thisVal,parentId){ 		
		if(parentId != null || parentId != undefined || parentId != ''){		
			j$('#'+thisVal).tooltipster({                    
				theme: 'tooltipster-shadow',
				content :'Loading...',
				updateAnimation:false,
				contentAsHTML:true, 
				interactive:true, 
				minWidth:100, 
				position:'right',   
							  
				functionBefore: function(origin, fetchLayout) {
					fetchLayout();
					Visualforce.remoting.Manager.invokeAction(
						_RemotingFlexTableActions.fetchLayout,parentId,
						function(result, event){
							if (event.status) {							
									resetSession();
								if(!jQuery.isEmptyObject(result)){
									tooltipContent =  '<div class="container-fluid">'+
												'<div class="panel border-ext">'; 
									tooltipContent = $scope.getMiniLayoutContent(result,origin);
									tooltipContent +='</div></div>';									
									origin.tooltipster('content', tooltipContent );									
								}else{									
									j$('#'+thisVal.id).tooltipster('hide');
								}
								
							}
					});
				}                   
			}); 
			j$('#'+thisVal).tooltipster('show');                
		}
	}; 
                
	$scope.getMiniLayoutContent = function(result,origin){
		var tooltip = tooltipContent;
		//console.log('RESULT',result);
		var tab = result.Tab;
		var record = result.Record;                           
		if(tab != null) {
		j$.each(result.Tab, function(i, tabVal) { 
		  j$.each(tabVal.pageBlocks, function(j, pageBlockVal) {  
			  tooltip +='<p class="tooltip-title">'+record ['Name']+'</p>';   
			  tooltip +='<div id="TooltipBody" class="panel-body">';
			  tooltip +='<form class="form-horizontal" role="form">'
			  j$.each(pageBlockVal.fields, function(k, field) {   
					if(field.hideField != 'true')   {                     
						tooltip += '<div class="form-group border-ext ">';
						tooltip += ' <div class="row">';                                   
							tooltip += ' <div class="col-md-4 col-xs-4 col-sm-4">';
							tooltip += field.fieldLabel;
							tooltip += '</div>';
					  
							var fieldVal =  j$('<span/>').html(encodeURI(record [field.fieldAPIName])).text(); 
							if(field.dataType == 'CURRENCY'){
								fieldVal = '$' + fieldVal;
							}
							tooltip += ' <div class="col-md-8 col-xs-8 col-sm-8" style="word-wrap:break-word; font-weight: bold;">';
							tooltip += decodeURI(fieldVal);     
							tooltip += '</div>';                                                                                     
						tooltip += '</div>';
						tooltip += '</div>';
						tooltip +='<br/>';
					}   
																		 
			  })
		  })
		})
		tooltip +='</form>';
		tooltip +='</div>';             
		}else {        				
			tooltip +='<p class="tooltip-title">'+record ['Name']+'</p>';
			tooltip +='<div id="TooltipBody" class="panel-body">';
			tooltip +='<form class="form-horizontal" role="form">';
			tooltip += '<div class="form-group border-ext ">';
			tooltip += ' <div class="row">';                                   
			tooltip += ' <div class="col-md-4 col-xs-4 col-sm-4">';
			tooltip += 'Name';
			tooltip += '</div>';				
			tooltip += ' <div class="col-md-8 col-xs-8 col-sm-8" style="word-wrap:break-word; font-weight: bold;">';
			tooltip += record ['Name'];     
			tooltip += '</div>';   
			tooltip += '</div>';
			tooltip += '</div>';
			tooltip +='</form>';
			tooltip += '</div>';
		}
		return tooltip;
	};
	
	$scope.hideTooltip= function(thisVal,parentId){ 
		 j$('#'+thisVal).tooltipster('hide'); 
	}
	$scope.applyStickySearch = function(stickySearchTerm,stickyFieldApiName,existingFilterCriteria){
		console.log('applyStickySearch----',applyStickySearch);		
		$scope.isRefresh = true;
		var newSearchCriteriaList = [];
		var newSearchCriteria='';
		stickySearchTerm += '';
		if($scope.pageNumber == 0){
			$scope.pageNumber = 1;
		}		
		if(stickySearchTerm){
			newSearchCriteriaList = stickySearchTerm.split(',');
			for(var i=0;i<newSearchCriteriaList;i++){
				newSearchCriteria += '\''+newSearchCriteriaList[i]+'\''+','
			}                   
			newSearchCriteria = newSearchCriteria.slice(0, -1);			         
			if($scope.newFilterClause){
				$scope.lastestFilterClause = existingFilterCriteria + 'AND '+stickyFieldApiName+' IN('+stickySearchTerm+')';
			}else{
				$scope.lastestFilterClause = 'WHERE '+stickyFieldApiName+' IN('+stickySearchTerm+')';
			}
		}else{
			$scope.lastestFilterClause = existingFilterCriteria;
		}   
				                       
		var paramMap = {};
		paramMap.queryColumns = $scope.queryColumns;
		paramMap.hideDecisionFields = $scope.hideDecisionFields;
		paramMap.objectName = $scope.objectName;
		paramMap.pageNumber = $scope.pageNumber;
		paramMap.pageSize = $scope.pageSize;
		paramMap.sortFieldName = $scope.sortFieldName;
		paramMap.sortDirection = $scope.sortDirection;
		paramMap.searchTerm = $scope.searchTerm;
		paramMap.newFilterClause = $scope.lastestFilterClause;
		paramMap.isSOSL = $scope.isSOSL;
		paramMap.stickySearchTerm = stickySearchTerm;
		paramMap.flexTableId = $scope.FlexTableRecordId;
		var paramMapString = JSON.stringify(paramMap);
		var deferred = $q.defer();
		Visualforce.remoting.Manager.invokeAction(
			_RemotingFlexTableActions.UpdateFlexTableWithStickySearch,paramMapString,                    
			function(flexTableResult, event){
				if (event.status) {
					resetSession();
					$scope.$apply(function () {
						deferred.resolve(flexTableResult);
						$scope.tableData = flexTableResult.RecordsList;
						$scope.noRecords = false;
						if($scope.tableData.length == 0){
							$scope.noRecords = true;
						}

						$scope.queryColumns = flexTableResult.QueryColumns;
						$scope.hideDecisionFields = flexTableResult.HideDecisionFields;
						$scope.objectName = flexTableResult.ObjectName;
						$scope.resultSize = flexTableResult.ResultSize;
						$scope.totalRecords = 'Total Records: '+ flexTableResult.ResultSize;
						$scope.pageNumber = flexTableResult.PageNumber;
						$scope.totalPages = flexTableResult.TotalPages;
						$scope.pageSize = flexTableResult.PageSize;
						$scope.hasNext = flexTableResult.HasNext;
						$scope.hasPrevious = flexTableResult.HasPrevious;
						$scope.pageInfo = 'Page ' + $scope.pageNumber + ' of ' +  $scope.totalPages;						
						$scope.setSelectAllCheckBox();
						$scope.windowURL = '' ;
						$scope.isRefresh = false;
					});
				}
				$scope.isSOSL = false;
				hideLoadingPopUp();			  
				adjustToggleBarHeightUI();
			},
			{ buffer: false, escape: false, timeout: 30000 }
		);
		return deferred.promise;
	};

	$scope.refreshLayoutSpecificFlexTables = function() {	   
		$scope.isRefresh = true;
		if($scope.pageNumber == 0){
			$scope.pageNumber = 1;
		}

		var deferred = $q.defer();
		Visualforce.remoting.Manager.invokeAction(
			_RemotingFlexTableActions.GetPageRecords,
			$scope.queryColumns,$scope.hideDecisionFields,$scope.objectName,$scope.pageNumber,$scope.pageSize,$scope.sortFieldName,$scope.sortDirection, $scope.searchTerm,$scope.newFilterClause,false,
			function(flexTableResult, event){
				if (event.status) {
					resetSession();
					$scope.$apply(function () {
						deferred.resolve(flexTableResult);
						
						$scope.tableData = flexTableResult.RecordsList;
						
						$scope.noRecords = false;
						if($scope.tableData.length == 0){
							$scope.noRecords = true;
						}
						$scope.queryColumns = flexTableResult.QueryColumns;
						$scope.hideDecisionFields = flexTableResult.HideDecisionFields;
						$scope.objectName = flexTableResult.ObjectName;
						$scope.resultSize = flexTableResult.ResultSize;
						$scope.totalRecords = 'Total Records: '+ flexTableResult.ResultSize;
						$scope.pageNumber = flexTableResult.PageNumber;
						$scope.totalPages = flexTableResult.TotalPages;
						$scope.pageSize = flexTableResult.PageSize;
						$scope.hasNext = flexTableResult.HasNext;
						$scope.hasPrevious = flexTableResult.HasPrevious;
						$scope.pageInfo = 'Page ' + $scope.pageNumber + ' of ' +  $scope.totalPages;
						
						$scope.setSelectAllCheckBox();
						$scope.windowURL = '' ;
						$scope.isRefresh = false;
					});
				}
				hideLoadingPopUp();				
				adjustToggleBarHeightUI();			 
			},
			{ buffer: false, escape: false, timeout: 30000 }
		);
		return deferred.promise;

	};
	/* Initialize the skinny flex table */
	$scope.initFlexSkinnyTable = function(){
		$scope.columns = [];
		$scope.setLoading(true);
		var deferred = $q.defer();
		if($scope.sortFieldName== undefined)
		{
			$scope.sortFieldName='';
		}
		if($scope.sortDirection== undefined)
		{
			$scope.sortDirection='';
		}
		
		
		console.log('sortDirection', $scope.sortDirection);
		Visualforce.remoting.Manager.invokeAction(
			_RemotingFlexTableActions.FetchInitialSearchData,
			$scope.flexTable_searchTerm,$scope.flexTable_objectName,$scope.flexTable_phaseName,$scope.flexTable_keyValueMap,$scope.flexTable_listKeyValueMap,$scope.sforce1,$scope.sortFieldName,$scope.sortDirection,
			function(flexTableResult, event){
				if (event.status) {
					resetSession();
					$scope.$apply(function () {
						deferred.resolve(flexTableResult);
						$scope.paintFlexTable(flexTableResult);
					});
					hideLoadingPopUp();
				} else{
					$scope.$apply(function () {
						$scope.errorCreatingTable = true;
						$scope.setLoading(false);
						$scope.messages.push({type: 'danger',msg: 'Error creating table:' + event.message});
					});
					hideLoadingPopUp();
			   }
			},
			{ buffer: false, escape: false}
		);
		return deferred.promise;
	};
	/* Initialize the flex table */

			
		
	/* Initialize the flex table */
	$scope.initFlexTable = function(){
		$scope.setLoading(true);
		var deferred = $q.defer();
		var filterMapInst = j$.cookie($scope.uniqueSessionId+"filterMapInst");
		if( filterMapInst != undefined && filterMapInst !='' ) {
			$scope.filterMap = j$.parseJSON( filterMapInst );
		}
		var filterDispMap = j$.cookie($scope.uniqueSessionId+"filterDispMap");
		if( filterDispMap != undefined && filterDispMap !='' ) {
			$scope.filterDisplayMap = j$.parseJSON( filterDispMap );
		}
		var pageNumber = j$.cookie($scope.uniqueSessionId+"pageNumber");
		if( pageNumber != undefined && pageNumber !='' ) {
			$scope.pageNumber = pageNumber;
			$scope.initialParameters['PageNumber'] = $scope.pageNumber;
		}
		var pageSize = j$.cookie($scope.uniqueSessionId+"pageSize");
		if( pageSize != undefined && pageSize !='' ) {
			$scope.pageSize = pageSize;
			$scope.initialParameters['PageSize'] = $scope.pageSize;
		}
		var sortFieldName = j$.cookie($scope.uniqueSessionId+"sortFieldName");
		if( sortFieldName != undefined && sortFieldName !='' ) {
			$scope.sortFieldName = sortFieldName;
			$scope.initialParameters['OrderBy'] = $scope.sortFieldName;
		}
		var sortDirection = j$.cookie($scope.uniqueSessionId+"sortDirection");
		if( sortDirection != undefined && sortDirection !='' ) {
			$scope.sortDirection = sortDirection;
			$scope.initialParameters['SortDirection'] = $scope.sortDirection;
		}
		$scope.generateFilterString( $scope.QuickSearchReportText );
		console.log('prem=====',$scope.flexTable_isN2GGridSearch);
		console.log('prem=====',$scope.flexTable_filterClauseGridSearch);		
		if($scope.flexTable_isN2GGridSearch == 'true' && $scope.flexTable_filterClauseGridSearch != ''){
			console.log('new filterclause should be given to remote method: ',$scope.flexTable_filterClauseGridSearch);
			$scope.newFilterClause = $scope.flexTable_filterClauseGridSearch;
			$scope.initialParameters['FilterClause'] = $scope.flexTable_filterClauseGridSearch;
			$scope.initialParameters['isN2GGridSearch'] = $scope.flexTable_isN2GGridSearch;
			if($scope.flexTable_gridSearchTerm != ''){				
				$scope.generateFilterString($scope.flexTable_gridSearchTerm);
			}
		}
		console.log('$scope.initialParameters fetchInitialDataWithFilter: ',$scope.initialParameters);
		Visualforce.remoting.Manager.invokeAction(
			_RemotingFlexTableActions.fetchInitialDataWithFilter,
			$scope.flexTable_dataTableConfigName ,$scope.flexTable_keyValueMap,$scope.flexTable_listKeyValueMap,$scope.sforce1,$scope.newFilterClause,$scope.initialParameters,
			function(flexTableResult, event){
				if (event.status) {
					resetSession();
					userTimeZone = flexTableResult.UserLocale;
					$scope.userOffset = getUserOffset(userTimeZone);
					$scope.$apply(function () {
						deferred.resolve(flexTableResult);
						console.log('flexTableResult=====',flexTableResult);						
						if(flexTableResult.DataTableInfo != undefined ){
							if($scope.flexTable_gridSearchTerm != ''){
								console.log('Enter into the flexabke search--1');								
								$scope.paintFlexTable(flexTableResult);	
								console.log('Enter into the flexabke search---2');	
								$scope.quickSearchCall($scope.flexTable_gridSearchTerm,null);							
							}else if(flexTableResult.DataTableInfo.RecordsList != undefined ){
								$scope.paintFlexTable(flexTableResult);
							}							
						}
					}); 
				}
				else{
					$scope.$apply(function () {
						$scope.errorCreatingTable = true;
						$scope.setLoading(false);
						$scope.messages.push({type: 'danger',msg: 'Error creating table:' + event.message});
					});
				}
				hideLoadingPopUp();
				
			},
			{ buffer: false, escape: false}
		);
		return deferred.promise;
	};

	/* Initializing history flex table*/
	$scope.initHistoryFlexTable = function(objName){
		//console.log('Into initHistoryFlexTable function!!!');
		$scope.setLoading(true);
		$scope.columns = [];
		$scope.pageSizes = [];				
		var deferred = $q.defer();
		Visualforce.remoting.Manager.invokeAction(
			_RemotingFlexTableActions.FetchInitialHistoryData,
			$scope.flexTable_dataTableConfigName ,objName,$scope.data.historyObj,$scope.flexTable_isFieldHistoryFlexTable,$scope.flexTable_parentRecord,$scope.flexTable_keyValueMap,$scope.flexTable_listKeyValueMap,$scope.sforce1,
			function(flexTableResult, event){
				if (event.status) {
					resetSession();
					$scope.$apply(function () {
						deferred.resolve(flexTableResult);						
						if(flexTableResult.DataTableInfo.RecordsList != undefined){
							$scope.paintFlexTable(flexTableResult);
						}
					});
				}
				else{
					$scope.$apply(function () {
						$scope.errorCreatingTable = true;
						$scope.setLoading(false);
						$scope.messages.push({type: 'danger',msg: 'Error creating table:' + event.message});
						hideLoadingPopUp();
					});
				}				
			},
			{ buffer: false, escape: false}
		);
		return deferred.promise;
	};
	
	$scope.closeFlexModal = function(){
		j$('#'+$scope.flexTableId+'modalDiv').modal('hide') ;
		$scope.getPageRecords();
	}


	/* Initialize the preview flex table */
	$scope.initFlexTablePreview = function(){
		//console.log('Initialize the preview flex table!!!');
		$scope.setLoading(true);
		var deferred = $q.defer();
		Visualforce.remoting.Manager.invokeAction(
			_RemotingFlexTableActions.FetchPreviewData,
			$scope.flexTable_dataTableConfigName ,$scope.sforce1,
			function(flexTableResult, event){
				if (event.status) {
					resetSession();
					$scope.$apply(function () {
						deferred.resolve(flexTableResult);
						$scope.paintFlexTable(flexTableResult);
					});
				}
				else{
					$scope.$apply(function () {
						$scope.errorCreatingTable = true;
						$scope.setLoading(false);
						$scope.messages.push({type: 'danger',msg: 'Error creating table:' + event.message});
						hideLoadingPopUp();
					});
				}
			},
			{ buffer: false, escape: false}
		);
		return deferred.promise;
	};

	//$scope.defaultFiscalValue = '';
	$scope.isHistory = false;
	/*Set the sforce1 varianle */
	if( (typeof sforce != 'undefined') && (sforce != null) ) {
		$scope.sforce1 = true;
	}else{
		$scope.sforce1 = false;
	}
	/* This is the initial load function called */ 
	if($scope.flexTable_dataTableConfigName  != ''){		
		$scope.isSkinnyTable = false;
		if($scope.flexTable_isPreview == 'true'){			
			$scope.initFlexTablePreview();
		}else if($scope.flexTable_isFieldHistoryFlexTable == 'true'){			
			$scope.initHistoryFlexTable($scope.flexTable_sObjectOfFieldHistory);
			$scope.isHistory = true;
		}else{			
			$scope.initFlexTable();
		}

	}else if($scope.flexTable_searchTerm !='' && $scope.flexTable_objectName != '' && $scope.flexTable_phaseName != ''){
		$scope.isSkinnyTable = true;
		$scope.initFlexSkinnyTable();
	}
	$scope.extraParameters = '?isdtp=vw&';

	if( flexTable_FiscalYear != '' &&  flexTable_FiscalYear != undefined && flexTable_FiscalYear != 'undefined'){
		$scope.extraParameters += 'pv0='+flexTable_FiscalYear+'&';
	}
	if( flexTable_Division != '' &&  flexTable_Division != undefined && flexTable_Division != 'undefined'){
		$scope.extraParameters += 'pv1='+flexTable_Division;
	}

});
flexTableApp.filter('orderObjectBy', function() {
	return function(items, field, reverse) {
		var filtered = [];
		angular.forEach(items, function(item) {
			filtered.push(item);
		});
		filtered.sort(function (a, b) {
			 return (a[field] > b[field]) ? 1 : ((a[field] < b[field]) ? -1 : 0);
		});
		if(reverse) filtered.reverse();
			return filtered;
	};
});
flexTableApp.filter('noFractionCurrency',[ '$filter', '$locale',
	function(filter, locale) {
		var currencyFilter = filter('currency');
		var formats = locale.NUMBER_FORMATS;
		return function(amount, currencySymbol) {
		  var value = currencyFilter(amount, currencySymbol);
		  var sep = value.indexOf(formats.DECIMAL_SEP);
		  if(amount >= 0) {
			return value;
		  }
		  return value;//.substring(0, sep) + '';
		};
	}
]);
flexTableApp.filter('percentage', ['$filter', function ($filter) {
  return function (input, decimals) {
	return $filter('number')(input , decimals) + '%';
  };
}]);
flexTableApp.directive("customhtml", function($compile,$parse){
	return {
		restrict: 'E',
		scope: {
			fieldContent: '=',
			fieldName: '='
		},
		link: function(scope, element, attr){
			var texAreaContent = $parse(scope.fieldName)(scope.fieldContent);
			var text = String(texAreaContent).replace(/<[^>]+>/gm, '');
			//to replace &amp; to & as it show title as &amp; for & character 
            text = text.replace(/&amp;/, '&');
			if(texAreaContent != undefined && texAreaContent != 'undefined'){
				var content = texAreaContent.replace(/PlaceHolderID/g, scope.flexTableId );
				element.html(content).show();
				element.attr('title', text);
				$compile(element.contents())(scope);
			}
		}
	}
});
flexTableApp.directive("autoComplete", function($filter) {

    var fetchDataForAutoSuggest = function(scope, element) {        
        var lookupval = scope.autoOptions.templateValue != '' ? scope.autoOptions.templateValue : 'Search...';
        scope.autoFilterClause =scope.autoFilterClause != undefined ?scope.autoFilterClause : '';
        console.log('scope---',scope);
        
        var s = element.select2({
            minimumInputLength: 1,
            placeholder: lookupval,
            allowClear: true,
            formatInputTooShort: function() {
                return "Please enter 1 or more character";
            },
            query: function(query) {
               
				Visualforce.remoting.Manager.invokeAction(
					_RemotingFlexTableActions.FetchLookupData,
					scope.autoOptions.selectedFilterColumn.refFieldValue, '',scope.autoOptions.selectedFilterColumn.referenceTo, query.term, scope.autoFilterClause,'',
					function(lookupResult, event) {
						if (event.status) {
							resetSession();
							scope.$apply(function() {
								
								var data = {
									results: []
								}
								data.results = lookupResult.SobjList;
								query.callback(data);
							});
						} else {
							scope.$apply(function() {});
						}
					}, {
						buffer: false,
						escape: false
					}
				);
            }
        });
		element.on('change', function (evt) {
        	console.log('event---',evt.added);
        	scope.$apply(function () {
        		if(evt.added != undefined){
                     scope.autoOptions.changeHandler(evt.added.id,evt.added.text);
                 }else{
                     scope.autoOptions.changeHandler(undefined,undefined);
                }
        	});
        });
		scope.$watch(   
          'autoOptions.templateValue',
           function(newValue, oldValue) {         	  
    	  	  if(scope.autoOptions.templateValue == ''){    	  		
	             lookupval = scope.autoOptions.templateValue != '' ? scope.autoOptions.templateValue : 'Search...'; 
			     console.log('------2-----------',s.select2("val", ""));  
    	  	 }
           }
        );
    }
	
    return {
        restrict: 'A',
        scope: {
            autoOptions: '=',
            autoFilterClause: '='
        },
        link: function(scope, element, attr) {            
            fetchDataForAutoSuggest(scope, element);
        }
    }
});
flexTableApp.directive("field", function($compile,$filter){
	var getFieldTemplate = function(options){
	    var template;
	    console.log('options===',options);
	    switch(options.type) {
		    case 'DATE':
		                template = '<input class="form-control" ng-model="options.templateValue" ng-change="options.changeDateHandler(options.templateValue);" type="text" format="m/d/Y"  time-picker="false" date-time-picker="angular" style="width:100%" aria-label="Enter DATE"/>';
		                break;
		    case 'DATETIME':
		                template = '<input class="form-control" ng-model="options.templateValue" ng-change="options.changeDateTimeHandler(options.templateValue);" type="text" format="m/d/Y  h:m A"  time-picker="true" date-time-picker="angular" style="width:100%" aria-label="Enter DATETIME"/>';
		                break;                                  
		    case 'STRING':
		                template = '<input class="form-control"  ng-change="options.changeHandler(options.templateValue);" ng-model="options.templateValue" type="text" style="width:100%" aria-label="Enter value"/>';
		                break;
            case 'EMAIL':
		                template = '<input class="form-control"  ng-change="options.changeHandler(options.templateValue);" ng-model="options.templateValue" type="text" style="width:100%" aria-label="Enter Email"/>';
		                break;
            case 'URL':
		                template = '<input class="form-control"  ng-change="options.changeHandler(options.templateValue);" ng-model="options.templateValue" type="text" style="width:100%" aria-label="Enter URL"/>';
		                break;
		    case 'PICKLIST':                        
						template = '<select class="form-control"  ng-model="options.templateValue" ng-options="opt for opt in options.picklistValues" ng-change="options.changeHandler(options.templateValue);" aria-label="Select PICKLIST value"></select>'; 
						break;
			case 'COMBOBOX':                        
						template = '<input class="form-control"  ng-change="options.changeHandler(options.templateValue);" ng-model="options.templateValue" type="text" style="width:100%" aria-label="Enter value"/>';
		                break;
			case 'MULTIPICKLIST':                        
						template = '<select class="form-control"  multiple="true"  ng-model="options.templateValue" ng-options="opt for opt in options.picklistValues" ng-change="options.changeHandler(options.templateValue);" aria-label="Select values"></select>'; 
						break;
		    case 'BOOLEAN':     
		                template = '<input style="display: table;height:15px;" class="form-control" type="checkbox" ng-model="options.templateValue" ng-change="options.changeHandler(options.templateValue);" aria-label="Enter Boolean value"/>'; 
		                break;  
		    case 'CURRENCY':  
		                 template = '<input class="form-control"  type="text" ng-focus="setValue(options.type);" ng-model="options.templateValue" ng-change="options.changeHandler(options.templateValue);" aria-label="Enter Currency value"/>';                                              
		                 break;
		    case 'DOUBLE':                        
		                 template = '<input class="form-control"  type="text" ng-model="options.templateValue" ng-change="options.changeHandler(options.templateValue);" aria-label="Enter Value"/>'; 
		                 break;
		    case 'INTEGER':                        
		                 template = '<input class="form-control"  type="number" ng-model="options.templateValue" ng-change="options.changeHandler(options.templateValue);" aria-label="Enter Value"/>'; 
		                 break;     
		    case 'REFERENCE':
		                template = '<input tabindex="0" class="textAreaContent" ng-model="options.templateValue" auto-options="options" auto-filter-clause="filterClause" type="text" auto-complete="angular" aria-label="Enter Value"/>';
		                break;                           
	                                                    
	    }
    	return template;
	}
  	return {
		restrict: 'E',
		scope: {
			options : '=',
			filterClause: '='
		},
      	link : function(scope,element,attr) {
	        var template = getFieldTemplate(scope.options);
	        var allowDecimal = true;
	        element.html(template).show();
	        $compile(element.contents())(scope);    
	        scope.$watch(   
	            'options.type',
	            function(newValue, oldValue) {  
	                var template = getFieldTemplate(scope.options);
	                allowDecimal = true;
	                element.html(template).show();
	                $compile(element.contents())(scope);    
	            }
	        );  
	        scope.customLookupModal = function() {
	            console.log('Custom Lookup Modal');
	        }                      
	        
    	}
	}
});
flexTableApp.directive("dateTimePicker", function($compile,$filter){
	return {
		restrict: 'A',
		scope: {
			timePicker: '=',
			format:'@'
		},
		require: 'ngModel',
		link: function(scope, element, attr,ngModel){
			ngModel.$formatters.push(function(value) {
				if( value != null && value != undefined && !isNaN(value)) {
					if(scope.timePicker == false){
						return $filter('date')(value, 'MM/dd/yyyy');
					}else{
						return $filter('date')(value, 'MM/dd/yyyy h:mm a');
					}
				}
				return '';
			});
			ngModel.$parsers.push(function (value) {
				return Date.parse(value);
			});
			element.datetimepicker({
				timepicker:scope.timePicker,
				format: scope.format
			});
		}
	}
});

flexTableApp.directive("stickySearch",function($q,$compile){
    return {
        restrict : 'A',
        scope : {
            stickySearchPlaceholder : '=', 
            stickySearchLastSearchTerm : '=',
            flexTable : '=',
            flexTableIdStickySearch : '=',
            parentScope : '='
        },
        link : function(scope,element,attr){            
            scope.flexTable_dataTableConfigName = scope.flexTable;          
            scope.flexTableId = scope.flexTableIdStickySearch;           
            var parentScope = scope.parentScope;                       
            var lastSearchTerms = [];
            var initData = [];
            var counter = 0;
            if(scope.stickySearchLastSearchTerm){
                lastSearchTerms = scope.stickySearchLastSearchTerm.split(',');              
                if(lastSearchTerms.length > 0){
                    for(var i=0; i<lastSearchTerms.length; i++){
                        var temp = lastSearchTerms[i].slice(1,-1);
                        counter++;
                        initData.push({id:temp,name:temp});
                    }
                }
            }   

            var jQueryMagicSuggest = j$('#StickySearchTableId'+scope.flexTable_dataTableConfigName ).magicSuggest({
                width:250,                              
                allowFreeEntries : false,
                hideTrigger: false,
                toggleOnClick: false,
                expanded: false,
                expandOnFocus: false,
                highlight: true,
                selectionPosition:'inner', 
                selectionStacked: true,                      
                matchCase:false, 
                strictSuggest: false,  
                maxSelection : 5,
                noSuggestionText : '',                                                                                                              
                placeholder : scope.stickySearchPlaceholder                                                                
            });             
            
            autoSuggestionObject[scope.flexTable_dataTableConfigName ] = jQueryMagicSuggest;            
            j$('.ms-trigger').children().remove();
            j$( "input[name*='StickySearch']" ).attr('aria-label','Search');// 508 
            j$('.ms-trigger').append('<i class="fa fa-search"></i>');
            var child = j$('.ms-trigger').children()
            j$(child).css('margin-left','5px');        
            jQueryMagicSuggest.setSelection(initData);                                            
            j$(jQueryMagicSuggest).on("keyup",function(e,m,v){
				//e.preventDefault();                
				if(v.keyCode == 37 || v.keyCode == 38 || v.keyCode == 39 || v.keyCode == 40 || v.keyCode == 13){
				}else{              
					var userInput = this.input[0].value;                
					userInput = userInput.replace(/[\%\*]/g, "");
					userInput = userInput.trim();               
					if(userInput.length == 0){
						j$(jQueryMagicSuggest)[0].setData([]);
						j$(jQueryMagicSuggest)[0].collapse();
					}else{                  
						this.expand(true);
						var paramMap ={};
						var filterClause='';
						var suggestions = [];
						paramMap.SearchCriteria = userInput;//this.input[0].value;
						paramMap.ObjectName = parentScope.StickyObjectName;
						paramMap.FieldApiName = parentScope.StickySearchFieldApiName;                       
						paramMap.newFilterClause = parentScope.newFilterClause;                         
						paramMap.lastSearchedTerm = scope.stickySearchLastSearchTerm;   
						paramMap.Counter = counter;

						if(scope.stickySearchLastSearchTerm == undefined){
							scope.stickySearchLastSearchTerm = '';
						}
						paramMap.existingFilterClause = parentScope.filterClause; 
						paramMap.Counter = counter;                              
						var paramMapString = JSON.stringify(paramMap);      
						
						var deferred = $q.defer();
						 Visualforce.remoting.Manager.invokeAction(
						_RemotingFlexTableActions.FetchStickySearchSuggestionsData,paramMapString,
							function(stickySearchSuggestions,event){
								if(event.status){
									scope.$apply(function(){
										deferred.resolve(stickySearchSuggestions);                                  
										suggestions = stickySearchSuggestions.SuggestionList;
										if(suggestions){                                        
											j$(jQueryMagicSuggest)[0].setData(suggestions); 
											if(v.keyCode != 13){
												j$(jQueryMagicSuggest)[0].expand();                          
											}                                                
										}
									});
								}else{
									alert(event.message);
								}
							},
							{buffer:true,escape:false}
						);
					}                 
				}                           
			});
            
			j$(jQueryMagicSuggest).on('selectionchange', function(e,m){
				j$(jQueryMagicSuggest)[0].collapse();               
				var selected  = this.getSelection();                                             
				var searchTerm = '';
				if(selected.length > 0){
					for(var i=0; i<selected.length; i++){
						counter++;                      
						var selectedName = selected[i].name.trim();
						selectedName = selectedName.replace(/'/g,"\\'");
						searchTerm += '\''+selectedName+'\''+',';
					}   
					searchTerm  = searchTerm.slice(0, -1);
					parentScope.StickySearchCriteria = parentScope.StickySearchFieldApiName+' IN('+searchTerm+')';                             
					parentScope.StickyUserSelection = searchTerm;
				}else{      
					counter = 1;  
					j$(jQueryMagicSuggest)[0].setData([]);                                                                                          
					parentScope.StickySearchCriteria = '';
					parentScope.StickyUserSelection = '';  
					parentScope.StickySearchLastSearchTerm = '';                            
				} 
				scope.stickySearchLastSearchTerm = searchTerm;                      
				var quickSearchText = parentScope.QuickSearchReportText;                    
				if(!parentScope.isFilterCriteriaChanged){
					parentScope.generateFilterString(quickSearchText);  
					parentScope.isStickySelectionChanged = true;  
					console.log('---applyStickySearch---');  
					parentScope.getPageRecords();
					parentScope.$apply();                               
				}                                                                           
			});                                                             
        }
    }
});                  

flexTableApp.filter('millSecondsToTimeString', function() {
	return function(millseconds) {
		var seconds = Math.floor(millseconds / 1000);
		var days = Math.floor(seconds / 86400);
		var hours = Math.floor((seconds % 86400) / 3600);
		var minutes = Math.floor(((seconds % 86400) % 3600) / 60);
		var timeString = '';
		if(days > 0) timeString += (days > 1) ? (days + " days ") : (days + " day ");
		if(hours > 0) timeString += (hours > 1) ? (hours + " hours ") : (hours + " hour ");
		if(minutes >= 0) timeString += (minutes > 1) ? (minutes + " minutes ") : (minutes + " minute ");
		return timeString;
	}
});

flexTableApp.factory('Scopes', function ($rootScope) {
    var mem = {}; 
    return {
        store: function (key, value) {
            $rootScope.$emit('scope.stored', key);
            mem[key] = value;
        },
        get: function (key) {
            return mem[key];
        }
    };
});