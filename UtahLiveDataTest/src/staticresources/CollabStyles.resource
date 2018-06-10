	/* New Styles */
	a.noUnderline,
	a.noUnderline:focus,
	a.noUnderline:hover,
	a.noUnderline:active {
		text-decoration: none !important;
	}
	
	/* Collab Info Styles */
	.profileOverview span,
	.profileOverview a {
		overflow: hidden;
		white-space: nowrap;
		text-overflow: ellipsis;
	}
	.profileOverview * {
		font-size: 1em;
	}
	.profileOverview {
		min-height: 1000px;
		position: relative;
		width: 710px;
		padding: 10px;
	}
	.profileOverview div {
		float: left;   
		display: block;
	}
	.profileOverview .collabContact > div + div {
		width: 50%;    
		clear: none;
	}
	.profileOverview > div:first-child,
	.profileOverview .filesOwned {
		width: 69%;
		margin-right: 2%;
	}
	.profileOverview > div:first-child + div,
	.profileOverview .profileGroups,
	.profileOverview .following {
		width: 29%;   
	}
	.profileOverview .aboutMe,
	.profileOverview .aboutMe + div {
		margin-top: 5px;   
	}
	.profileOverview .infoContainer {
		min-height: 50px;   
		position: relative;
	}
	.profileOverview .infoContainer > div:first-child {
		font-weight: bold;
		border-bottom: 1px solid #d7dbde;
		margin-top: 5px;
		margin-bottom: 5px;
	}
	.profileOverview .infoContainer > div:first-child > a {
		font-weight: normal;
		float: right;
	}
	.profileOverview .infoContainer > div {
		word-wrap: break-word;
	}
	.profileOverview > div > div {
		position: relative;   
	}
	.profileOverview > div:first-child > div,
	.profileOverview .infoContainer div,
	.profileOverview .followers,
	.profileOverview .following {
		clear: both;
		width: 100%;
	}
	.profileOverview .following > div.profile,
	.profileOverview .followers > div + div {
		float: left;
		clear: none;
		width: auto;
	}
	.profileOverview .followers > div > a,
	.profileOverview .following > div.profile > a {
		padding: 0 4px 4px 0;
		vertical-align: top;
		float: left;
	}
	.profileOverview .followers > div > a > img,
	.profileOverview .following > div.profile > a > img {
		height: 30px;
		width: 30px;
		float: left;
	}
	.profileOverview .profileGroups span {
		width: 100%;
		clear: both;
		display: block;
	}
	.profileOverview .profileGroups .groupInfo {
		margin-top: 7px;
	}
	.profileOverview .profileGroups .groupInfo > a > img {
		float: left;   
		height: 30px;
		width: 30px;
		margin-right: 7px;
	}
	.profileOverview .profileGroups .groupInfo > div {
		float: left;   
		clear: none;
		width: 100px;
	}
	.profileOverview .profileGroups .groupInfo > div > * {
		height: 14px;
		width: 100%;
		display: block;
	}
	.profileOverview .filesOwned > div + div {
		margin-top: 3px;    
	}
	.profileOverview .filesOwned .fileDiv {
		width: 16px;   
		float: left;
		display: block;
	}
	.profileOverview .filesOwned .fileDiv,
	.profileOverview .following > div.file > a,
	#ShowAllProfileModal > ul.collabProfileModalList > li.file > div:first-child > a {
		padding-left: 20px;
		height: 16px;
		display: block;
		/*background: url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabSmallExtensionImages.png')}) no-repeat 0px 0px;*/
	}
	#ShowAllProfileModal .filterTypeWrapper {
		display: none;   
	}
	#ShowAllProfileModal .filterTypeWrapper.active {
		display: block;   
	}
	#ShowAllProfileModal > ul.collabProfileModalList {
		width: 390px;
		margin: 0px 5px 30px 5px;
		padding: 0px;
		list-style-type: none;
		float: left;
		position: relative;
	}
	#ShowAllProfileModal > div {
		padding-bottom: 5px;
		padding-top: 5px;
		margin-left: 5px;
		margin-right: 5px;
		clear: both;
		border-bottom: 1px solid gray;
	}
	#ShowAllProfileModal > ul.collabProfileModalList > li {
		width: 380px;
		height: 44px;
		float: left;
		padding-bottom: 5px;
		padding-top: 5px;
		margin-left: 5px;
		margin-right: 5px;
		clear: both;
		border-bottom: 1px solid gray;
	}
	#ShowAllProfileModal > ul.collabProfileModalList > li.file {
		height: 26px;   
	}
	#ShowAllProfileModal > ul.collabProfileModalList > li.file > div:first-child {
		margin-right: 20px;
		width: 250px;
	}
	#ShowAllProfileModal > ul.collabProfileModalList > li > a {
		white-space: nowrap;
		text-overflow: ellipsis;
		overflow: hidden;
		width: 100%;
		float: left;
	}
	#ShowAllProfileModal > ul.collabProfileModalList > li > div:first-child {
		float: left;
		clear: left;
	}
	#ShowAllProfileModal > ul.collabProfileModalList > li > div.profileGroup > div {
		float: left;   
	}
	#ShowAllProfileModal > ul.collabProfileModalList > li > div:first-child > a.profileImage {
		float: left;
		display: block;
		width: 34px;
	}
	#ShowAllProfileModal > ul.collabProfileModalList > li > div:first-child > a + a {
		float: left;
		display: block;
		overflow: hidden;
		text-overflow: ellipsis;
		width: 220px;
		margin-right: 20px;
	}
	#ShowAllProfileModal > ul.collabProfileModalList > li > div.profileGroup > div > a {
		display: block;
		height: 16px;
		overflow: hidden;
		text-overflow: ellipsis;
		white-space: nowrap;
		float: left;
		clear: right;
		width: 200px;
	}
	#ShowAllProfileModal > ul.collabProfileModalList > li > div.profileGroup > div > span {
		display: block;   
	}
	#ShowAllProfileModal > ul.collabProfileModalList > li > div:first-child + div {
		float: left;  
	}
	#ShowAllProfileModal > ul.collabProfileModalList > li > div:first-child + div > a { 
		padding: 8px 0px 0px 20px;
		float: left;
		display: inline;
		/*background: url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabFollowSprite.png')}) no-repeat 0px 7px;*/
	}
	#ShowAllProfileModal > ul.collabProfileModalList > li.file > div:first-child + div > a { 
		background-position: 0px 0px;
	}
	#ShowAllProfileModal > ul.collabProfileModalList > li.file > div:first-child + div > a {
		padding-top: 0px;   
	}
	#ShowAllProfileModal > ul.collabProfileModalList > li > div:first-child + div > a:hover,
	#ShowAllProfileModal > ul.collabProfileModalList > li > div:first-child + div > a:focus,
	#ShowAllProfileModal > ul.collabProfileModalList > li > div:first-child + div > a:active {
		text-decoration: none;   
	}
	#ShowAllProfileModal > ul.collabProfileModalList > li > div:first-child + div > a.following { 
		background-position: 0px -19px;
	}
	#ShowAllProfileModal > ul.collabProfileModalList > li.file > div:first-child + div > a.following { 
		background-position: 0px -26px;
	}
	#ShowAllProfileModal > ul.collabProfileModalList > li > div:first-child + div > a > span { 
		display: inline;
		width: 16px;
		height: 16px;
		float: right;
		margin-left: 5px;
		/*background: url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabFollowSprite.png')}) no-repeat 0px -54px;*/
	}
	#ShowAllProfileModal > ul.collabProfileModalList > li > div:first-child + div > a > span:hover,
	#ShowAllProfileModal > ul.collabProfileModalList > li > div:first-child + div > a > span:focus,
	#ShowAllProfileModal > ul.collabProfileModalList > li > div:first-child + div > a > span:active { 
		background-position: 0px -75px;
	}
	#ShowAllProfileModal > ul.collabProfileModalList img {
		margin: 2px;
		height: 30px;
		width: 30px;
	}
	#ShowAllProfileModal > ul.collabProfileModalList > li.nextProfileModalPage {
		width: 35px;
		position: absolute;
		right: 6px;
		bottom: -27px;
		border: none;
		height: auto;
	}
	#ShowAllProfileModal > ul.collabProfileModalList > li.prevProfileModalPage {
		width: 35px;
		position: absolute;
		left: 6px;
		bottom: -27px;
		border: none;
		height: auto;
	}
	#ShowAllProfileModal > ul.collabProfileModalList > li.nextProfileModalPage > a {
		width: 28px;
	}
	#ShowAllProfileModal > ul.collabProfileModalList > li.prevProfileModalPage > a {
		width: 28px;
	}
	#ShowUserFiles a.actionClose {      
		position: absolute;
		right: 5px;
		top: 0px;        
	}
	#ProfileLoadingModal > div {
		height: 120px;
		padding: 10px;
	}
	#ProfileLoadingModal img {
		margin-left: 124px;
		margin-top: 34px;
	}
		
	/* Collab Groups Styles */
	/*
	.collabGroups * {
		font-size: 1em;
	}*/
	.collabGroups {
		float: left;
		width: 100%;
		min-width: 651px;
		min-height: 300px;
		/*max-height: 600px;*/
		/*overflow-y:auto;*/
	}
	.collabModal {
		display: none;
	}
	.collabModal.active {
		display: block;
	}
	.groupsTableBackground {
		float: left;
		width: 100%;
		margin-bottom: 15px;
		width: 100%;
	}
	div.ui-dialog-titlebar {
		display: none;
	}
	
	div.ui-dialog-content {
		padding: 0px !important;
	}
	
	div.ui-dialog.ui-widget-content {
		padding: 0px;
		border-radius: 6px 6px 0px 0px !important;
		border: none;
	}
	
	div.ui-widget-content a {
		color: #428BCA;
	}
	.collabGroups > div:first-child .newCollabGroup {
		position: absolute;
		top: 2px;
		right: 338px;
	}
	.collabGroups > div:first-child #GroupsSearchCancelButton {
		position: absolute;
		top: 2px;
		right: 15px;
	}
	.collabGroups > div:first-child #GroupsSearchButton {
		position: absolute;
		top: 2px;
		right: 89px;
	}
	.collabGroups > div:first-child input.searchCollabGroups {
		position: absolute;
		right: 174px;
		top: 5px;
		color: #ccc;
	}
	.collabGroups > div:first-child input.searchCollabGroups.textFieldActive{
		color:#000;
	}
	/*
	.collabGroups > div:first-child + div {
		float: left;
		padding-left: 5px;
		padding-right: 5px;
	}*/
	.collabGroups > div:first-child > div {
		position: relative;
	}
	.collabGroups > div:first-child {
		//margin-bottom: 20px;
	}
	.collabGroups > div:first-child,
	.collabGroups > div:first-child div {
		float: left;
		width: 100%;
		padding-top: 0px !important;
		padding-bottom: 0px !important;
	}
	.collabGroups > div:first-child h2 {
		float: left;
	}
	/*
	.collabGroups > div + div > div {
		width: 160px;
		float: left;
		padding-left: 5px;
		padding-right: 5px;
		padding-bottom: 20px;
		position: relative;
	}
	.collabGroups > div + div > div > .tabColor {
		padding-right: 25px;
	}
	*//*
	.collabGroups > .collabGroupsWrapper > .panel-default > .groupsInfo.panel-heading {
		border-radius: 0px !important;
		position: relative;
		padding: 5px !important;
	}
	.collabGroups .groupsInfo.panel-heading > div:first-child {
		overflow: hidden;
		text-overflow: ellipsis;
		white-space: none;
	}
	.collabGroups .groupsInfo.panel-heading > div:first-child + div {
		padding-bottom: 5px;
	}
	.collabGroups .groupsInfo.panel-heading > div:first-child > a {
		width: 80px;
		overflow: hidden;
		white-space: nowrap;
		text-overflow: ellipsis;
		overflow: hidden;
	}
	.collabGroups .groupsInfo.panel-heading > div:first-child > a,
	.collabGroups .groupsInfo.panel-heading > div:first-child > span {
		height: 14px;
	}*/
	.collabGroups .imageAnchor {
		position: relative;
		display: inline-block;
	}
	.collabGroups .groupImage {
		width: 80px;
		height: 80px;
		margin-right: 15px;
	}
	/*
	.collabGroups a.collabGroupsButton:focus,
	.collabGroups a.collabGroupsButton:active,
	.collabGroups a:hover > .groupImage,
	.collabGroups a:focus > .groupImage,
	.collabGroups a:active > .groupImage {
		outline: 1px auto;
		outline-style: solid;
	}*/
	.collabGroups .externalFlag {
		position: absolute;
		height: 20px;
		display: block;
		top: 0px;
		left: 0px;
		/*background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabAvatarSprite.png')}) no-repeat 0px 0px;*/
	}
	.collabGroups .collabLock {
		position: absolute;
		height: 15px;
		display: block;
		bottom: -2px;
		right: 20px;
		/*background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabLocksAndKeys.png')}) no-repeat 0px -34px;*/
	}
	.collabGroups .groupHeader {
		margin-bottom: 0px;
		cursor: default;
		text-overflow: ellipsis;
		white-space: nowrap;
		overflow: hidden;
	}
	.collabGroups .collabGroupsButton {
		position: absolute;
		top: 33px;
		right: 20px;
		height: 16px;
		width: 16px;
		/*background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabFollowSprite.png')}) no-repeat 0px 0px;*/
	}
	/*
	.collabGroups .collabGroupsButton.member {
		background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabFollowSprite.png')}) no-repeat 0px -27px;
	}
	.collabGroups .collabGroupsButton.requested {
		background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabFollowDisabled.png')}) no-repeat 0px 0px;
	}
	.collabGroups .collabGroupsButton.declined {
		background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabSprites.png')}) no-repeat 0px-502px;
	}
	.collabGroups .collabGroupsButton.member:active,
	.collabGroups .collabGroupsButton.member:hover,
	.collabGroups .collabGroupsButton.member:focus {
		background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabFollowSprite.png')}) no-repeat 0px -74px;
	}*/
	/*
	.collabGroups > .panel-default > .panel-heading {
		float: left;
		width: 100%;
	}
	.collabGroups > .panel-default > .panel-heading > div {
		float: left;
		clear: left;
	}*/
	.loadingCollabGroups {
		float: left;
		clear: both;
		display: none;
		width: 170px;
		height: 170px;
		margin-left: 270px;
		margin-top: 25px;
		/*background: transparent url({!urlfor($Resource.GovGrantsExternal, 'Feedback/css/ajax-loader.gif')}) no-repeat 0px 0px;*/
	}
	.loadingCollabGroups.active{
		display: block;
	}
	#CollabNewGroupModal .requiredBlock {
		background-color: #c00;
		position: absolute;
		right: 2px;
		width: 3px;
		top: 0px;
		bottom: 1px;
	}
	#CollabNewGroupModal > div {
		float: left;
		width: 100%;
		padding: 10px;
		padding-bottom: 20px;
	}
	#CollabNewGroupModal > div > div > div,
	#CollabNewGroupModal .groupAllow  {
		float: left;
		clear: both;
		width: 100%;
	}
	#CollabNewGroupModal > div > div:first-child {
		float: left;
		width: 150px;
		font-wieght: bold;
	}
	#CollabNewGroupModal > div > div:first-child + div {
		float: left;
		width: 500px;
	}
	#CollabNewGroupModal > div > div:first-child + div > div + div + div + div.groupArchiveInput {
		margin-bottom: 2px;
	}
	#CollabNewGroupModal .groupName {
		padding-top: 3px;
		padding-bottom: 3px;
		vertical-align: middle;
		position: relative;
	}
	#CollabNewGroupModal .groupVisible,
	#CollabNewGroupModal .groupVisible,
	#CollabNewGroupModal .groupAllow {
		position: relative;
	}
	#CollabNewGroupModal .groupAllow {
		display: block;
	}
	#CollabNewGroupModal .groupVisible > span,
	#CollabNewGroupModal .groupVisible > span,
	#CollabNewGroupModal .groupAllow > span {
		position: absolute;
		top: 2px;
		left: 17px;
	}
	#CollabNewGroupModal .groupDescription {
		padding-top: 43px;
		padding-bottom: 42px;
		vertical-align: middle;
		margin-top: 5px;
	}
	#CollabNewGroupModal .groupDescriptionInput > textarea {
		margin-top: 5px;
		resize: none;
		height: 100px;
		width: 450px;
	}
	#CollabNewGroupModal .groupArchive {
		padding-top: 15px;
		padding-bottom: 15px;
		vertical-align: middle;
	}
	.collabModal > a {
		position: absolute;
		right: 10px;
		top: 5px;
		height: 20px;
		width: 20px;
		z-index: 1;
		/*background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabXButtons.png')}) no-repeat 0px 0px;*/
	}
	#CollabNewGroupModal .groupAllowInput,
	#CollabNewGroupModal .groupPrivateInput {
		padding-top: 2px;
		padding-bottom: 3px;
		vertical-align: middle;
		display: block;
	}
	#CollabNewGroupModal .groupAllowInput {
		padding-top: 4px;
	}
	#CollabNewGroupModal .addPadding {
		padding-top: 20px;
	}
	/* UI-Shrawan-10202015 */
	.collabGroups .container-fluid {
		width: 100%;
		display: inline-block;
	}
	.collabGroups .container-fluid input{
		margin: 5px 5px;
		float: right;
	}
	.collabGroups .panel-body{
		overflow-y: auto;
	}
	.contentWrapper {
		margin: 5px 0px;
		padding: 10px 0px;
		border-bottom: 1px solid #DCDCDC;
	}
	.groupOwnerMem span{
		margin-right: 50px;
	}
	.groupsInfo {
		display: inline-block;
	}
	.groupsInfo p{
		margin: 5px !important;
	}
		
	/* Collab Files Styles */
	td {
		background-clip: padding-box;
	}
	#bodyDivId.bodyDiv.container-fluid {
		overflow: visible;
		margin-bottom: 20px;
	}
	#FilesDataTable * {
		font-size: 1em;
	}
	#FilesDataTable {
		padding-bottom: 20px;
	}
	.tableBackground.collabFilesWrapper {
		width: 100%;
		min-width: 600px;
		border-radius: 7px 7px 0px 0px !important;
		margin-bottom: 20px;
	}
	.collabModal {
		display: none;
	}
	.collabModal.active {
		display: block;
	}
	div.ui-dialog-titlebar {
		display: none;
	}
	#table-border-code {
		border:1px solid black !important;
	   
	  }
	
	div.ui-dialog-content {
		padding: 0px !important;
	}
	
	div.ui-dialog.ui-widget-content {
		padding: 0px;
		border-radius: 6px 6px 0px 0px !important;
		border: none;
	}
	
	div.ui-widget-content a {
		color: #428BCA;
	}
	.collabFilesWrapper.tableBackground .panel.panel-default > .collabPanelHeading.panel-heading {
		border-radius: 6px 6px 0px 0px !important;
	}
	#UploadNewVersion > a {
		position: absolute;
		right: 10px;
		top: 5px;
		height: 20px;
		width: 20px;
		z-index: 1;
		/*background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabXButtons.png')}) no-repeat 0px 0px;*/
	}
	.collabFilesWrapper .panel-heading,
	.collabFilesWrapper .panel-heading-title{
		padding-top:0px !important;
		padding-bottom:0px !important; 
		display:block; 
		float:left; 
		width:100%;
	}
	.collabFilesWrapper .panel-heading-title h2{
		display:block;
		float:left;
	}
	.collabFilesWrapper table.dataTable{
		box-sizing: border-box;
		border-collapse: collapse;
		border-spacing: 0;
		margin-top:20px;
	}

	.collabFilesWrapper table.dataTable .headerRow{
		background: #e1e1e1;
		background: url(data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiA/Pgo8c3ZnIHhtbG5zPSJod?BoZWlnaHQ9IjEiIGZpbGw9InVybCgjZ3JhZC11Y2dnLWdlbmVyYXRlZCkiIC8+Cjwvc3ZnPg==);
		background: -moz-linear-gradient(top, #e1e1e1 35%, #828282 100%);
		background: -webkit-gradient(linear, left top, left bottom, color-stop(35%,#e1e1e1), color-stop(100%,#828282));
		background: -webkit-linear-gradient(top, #e1e1e1 35%,#828282 100%);
		background: -o-linear-gradient(top, #e1e1e1 35%,#828282 100%);
		background: -ms-linear-gradient(top, #e1e1e1 35%,#828282 100%);
		background: linear-gradient(to bottom, #e1e1e1 35%,#828282 100%);
		filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#e1e1e1', endColorstr='#828282',GradientType=0 );
	}
	.collabFilesWrapper table.dataTable thead th{
		border: 1px solid #ddd;
		border-bottom: 2px solid #ddd;
		padding:8px !important;
	}
	.collabFilesWrapper table.dataTable th.sorting_desc,
	.collabFilesWrapper table.dataTable th.sorting_asc,
	.collabFilesWrapper table.dataTable th.sorting{
		background-image: none;
	}
	.collabFilesWrapper table.dataTable th.sorting_desc:before,
	.collabFilesWrapper table.dataTable th.sorting_asc:before {
		content: "\e094";
		position: relative;
		top: 1px;
		display: block;
		float:left;
		font-family: 'Glyphicons Halflings';
		font-style: normal;
		font-weight: 400;
		line-height: 1;
		-webkit-font-smoothing: antialiased;
	}
	.collabFilesWrapper table.dataTable th.sorting_asc:before{
		content: "\e093";
	}
	.collabFilesWrapper table.dataTable td{
		border: 1px solid #ddd;
		padding: 8px;
		background-color: #fff !important;
		position: relative;
	}
	.collabFilesWrapper table.dataTable td a.pencil {
		height: 12px;
		width: 12px;
		padding: 3px;
		display: block;
		position: absolute;
		right: 0px;
		top: 14px;
		/*background: url({!urlfor($Resource.GovGrantsExternal, 'Feedback/css/icons.png')}) no-repeat -19px -96px;*/
	}
	.collabFilesWrapper table.dataTable + .bottom{padding-top:20px;}
	.collabFilesWrapper table.dataTable + .bottom .dataTables_paginate{
		float:left;
		padding-right:28px;
		position: relative;
	}
	.collabFilesWrapper table.dataTable + .bottom .dataTables_paginate a{
		float:left;
	}
	.collabFilesWrapper table.dataTable + .bottom .dataTables_length{float:right;}

	.collabFilesWrapper .pageOfPages,
	.collabFilesWrapper table.dataTable + .bottom .dataTables_paginate .paginate_disabled_previous,
	.collabFilesWrapper table.dataTable + .bottom .dataTables_paginate .paginate_disabled_next,
	.collabFilesWrapper table.dataTable + .bottom .dataTables_paginate .paginate_enabled_previous,
	.collabFilesWrapper table.dataTable + .bottom .dataTables_paginate .paginate_enabled_next{
		float:left;
		display: block;
		width:auto;
		padding:0px;
		margin:0px;
		background:none !important;
	}
	.collabFilesWrapper table.dataTable + .bottom .dataTables_paginate .paginate_disabled_previous,
	.collabFilesWrapper table.dataTable + .bottom .dataTables_paginate .paginate_disabled_next,
	.collabFilesWrapper table.dataTable + .bottom .dataTables_paginate .paginate_enabled_previous,
	.collabFilesWrapper table.dataTable + .bottom .dataTables_paginate .paginate_enabled_next{
		text-indent: 100%;
		white-space: nowrap;
		overflow: hidden;
		width: 18px;
		margin-left:8px;
	}



	.collabFilesWrapper table.dataTable + .bottom .dataTables_paginate .paginate_disabled_previous:before,
	.collabFilesWrapper table.dataTable + .bottom .dataTables_paginate .paginate_disabled_next:before,
	.collabFilesWrapper table.dataTable + .bottom .dataTables_paginate .paginate_enabled_previous:before,
	.collabFilesWrapper table.dataTable + .bottom .dataTables_paginate .paginate_enabled_next:before{
		content: "\e071";
		position: relative;
		top: 1px;
		display: block;
		float:left;
		font-family: 'Glyphicons Halflings';
		font-style: normal;
		font-weight: 400;
		line-height: 1;
		-webkit-font-smoothing: antialiased;
		text-indent: 0px;
		color:#428bca;
		background:none !important;
	}
	.collabFilesWrapper table.dataTable + .bottom .dataTables_paginate .paginate_disabled_previous:before,
	.collabFilesWrapper table.dataTable + .bottom .dataTables_paginate .paginate_disabled_next:before{
		color:#eee;
	}
	.collabFilesWrapper table.dataTable + .bottom .dataTables_paginate .paginate_disabled_next,
	.collabFilesWrapper table.dataTable + .bottom .dataTables_paginate .paginate_enabled_next{
		position: absolute;
		right:0px;
	}
	.collabFilesWrapper table.dataTable + .bottom .dataTables_paginate .paginate_disabled_next:before,
	.collabFilesWrapper table.dataTable + .bottom .dataTables_paginate .paginate_enabled_next:before{
		content: "\e075";

	}
	.collabFilesWrapper table.dataTable + .bottom .dataTables_length{
		margin-right: 50px;
	}
	.collabFilesWrapper table.dataTable .fileDescription {
		word-break: break-word;
	}
	.collabFilesWrapper .pageOfPages{
		float: left;
	}

	.collabFilesWrapper .dataTables_filter{
		display:none;
	}
	.collabFilesWrapper .collabDialogHeading {
		position: relative;
		margin-bottom: 0px;
	}
	.collabFilesWrapper .collabPanelHeading {
		position: relative;
		margin-bottom: 20px;
	}
	.collabFilesWrapper table.dataTable .actionList{
		margin:0px auto;
		width:63px;
		position: relative;
	}
	.collabFilesWrapper a.actionClose {
		text-indent: -99999px;
		line-height: 1px;
		float: right;
		height: 20px;
		width: 20px;
		margin-top: 6px;
		margin-left: 15px;
		/*background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabXButtons.png')}) no-repeat 0px 0px;*/
	}
	.collabFilesWrapper a.actionClose:hover,
	.collabFilesWrapper a.actionClose:active,
	.collabFilesWrapper a.actionClose:focus {
		background-position: 0px -20px;
	}
	.collabFilesWrapper table.dataTable .actionPreview,
	.collabFilesWrapper table.dataTable .actionFollow,
	.collabFilesWrapper table.dataTable .actionDropdown,
	.collabFilesWrapper table.dataTable .actionAttach,
	.collabFilesWrapper table.dataTable .actionUnfollow {
		display:block;
		float:left;
		height:18px;
		width:16px;
		margin-right:5px;
		text-indent: -99999px;
		font-size: 1px;
		overflow: hidden;
		cursor: pointer;
	}
	/*
	.collabFilesWrapper table.dataTable .actionPreview {
		background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabFiles.png')}) no-repeat 0px -4px;
	}
	.collabFilesWrapper table.dataTable .actionFollow {
		background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabFollowSprite.png')}) no-repeat 0px 0px;
	}
	.collabFilesWrapper table.dataTable .actionFollow.following {
		background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabFollowSprite.png')}) no-repeat 0px -26px;
	}*/
	.collabFilesWrapper table.dataTable a.actionDropdown {
		background-color: #f8f8f8;
		border: 1px solid #e2e2e2;
		padding: 5px 4px 5px 4px;
		border-radius: 3px !important;
		width: 15px;
		height: 15px;
		display: block;
	}
	.collabFilesWrapper table.dataTable a.actionDropdown > span {
		display: block;
		height: 4px;
		width: 5px;
		/*background: #f8f8f8 url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabSprites.png')}) no-repeat 0px -1634px;*/
	}
	.collabFilesWrapper table.dataTable .actionAttach {
		text-indent: 0px;
		width: initial;
		font-size: 1em;
		background: #FFF;
	}
	.collabFilesWrapper table.dataTable .collabFileName > span:first-child {
		width: 32px;
		height: 32px;
		vertical-align: middle;
		float: left;
		/*background-image: url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabExtensionImages.png')});*/
	}
	.collabFilesWrapper table.dataTable .collabFileName > div {
		padding-top: 9px;
		padding-left: 40px;
	}
	.collabFilesWrapper .collabFileName > span:first-child {
		font-size: 1px;
		text-indent: -99999px;
		color: transparent;
	}
	.collabFilesDropdownDiv {
		display: none;
		background-color: white;
		padding: 5px 5px 5px 5px;
		border-radius: 5px !important;
		position: absolute;
		z-index: 5;
		top: 20px;
		right: -154px;
		border: 1px solid #b6b6b6;
		width: 175px;
		box-shadow: rgb(160, 172, 171) 0px 2px 5px 0px;
	}
	.collabFilesDropdownDiv.active {
		display: block;
	}
	.collabFilesDropdownDiv > div{
		padding-top: 10px;
		float: left;
		width: 100%;
		clear: both;
		height: 32px;
		border-radius: 9px 9px 9px 9px !important;
	}
	.collabFilesDropdownDiv div:hover,
	.collabFilesDropdownDiv div:focus,
	.collabFilesDropdownDiv div:active {
		background-color: #cfeef8;
	}
	.collabFilesDropdownDiv a {
		float: left;
		padding-left: 15px;
		width: 100%;
		color: #222;
	}
	.collabFilesDropdownDiv a:hover,
	.collabFilesDropdownDiv a:focus,
	.collabFilesDropdownDiv a:active {
		color: #222;
		cursor: pointer;
		text-decoration: none;
	}
	/*
	.collabFilesDropdownDiv .collabActionDownload {
		background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabFiles.png')}) no-repeat 0px -22px;
	}
	.collabFilesDropdownDiv .collabActionUpload {
		background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabFiles.png')}) no-repeat 0px -38px;
	}*/
	.collabFilesWrapper table.dataTable .modifiedDate > span {
		float: right;
	}
	.collabModal > a {
		text-indent: -99999px;
		line-height: 1px;
		position: absolute;
		right: 10px;
		top: 5px;
		height: 20px;
		width: 20px;
		z-index: 1;
		/*background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabXButtons.png')}) no-repeat 0px 0px;*/
	}
	#CollabLoadingModal > div,
	#CollabDeleteModal > div {
		height: 120px;
		padding: 10px;
	}
	#CollabLoadingModal img {
		margin-left: 124px;
		margin-top: 34px;
	}
	#CollabDeleteModal > div > div:first-child + div {
		margin-top: 30px;
		float: right;
	}
	#CollabDeleteModal input + input {
		margin-left: 20px;
		margin-right: 50px;
	}
	#CollabFileSharingModal > div {
		padding: 15px;
		padding-top: 30px;
		float: left;
		width: 100%;
	}
	#CollabFileSharingModal > div > div:first-child + div {
		float: left;
		width: 100%;
	}
	#CollabFileSharingModal .shareWith,
	#CollabFileSharingModal .fileSharingHeader,
	#CollabFileSharingModal .fileSharingList {
		margin: 0;
		padding: 0;
		list-style-type: none;
	}
	#CollabFileSharingModal .fileSharingList {
		float: left;
		width: 616px;
		height: 200px;
		overflow-y: scroll;
	}
	#CollabFileSharingModal .shareWith {
		padding-bottom: 5px;
		padding-left: 20px;
		/*background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabFiles.png')}) no-repeat 0px -56px;*/
	}
	#CollabFileSharingModal .shareWith + a {
		position: absolute;
		right: 60px;
		top: 62px;
		font-weight: bold;
	}
	#CollabFileSharingModal .sharingDiv,
	#CollabFileSharingModal .makeFilePrivate {
		display: none;
	}
	#CollabFileSharingModal .sharingDiv.active,
	#CollabFileSharingModal .makeFilePrivate.active {
		display: block;
	}
	#CollabFileSharingModal .fileSharingHeader {
		float: left;
		border-bottom: 0px;
		width: 100%;
	}
	#CollabFileSharingModal .shareWith > li,
	#CollabFileSharingModal .fileSharingHeader > li,
	#CollabFileSharingModal .fileSharingList > li > div {
		display: inline;
		list-style: none;
	}
	#CollabFileSharingModal .fileSharingList > li:empty {
		display: none;
	}
	#CollabFileSharingModal .fileSharingList > li > div:first-child + div > a {
		font-weight: bold;
	}
	#CollabFileSharingModal .fileSharingList > li > div:first-child + div + div > a > span {
		width: 16px;
		height: 8px;
		margin-top: 2px;
		float: right;
		/*background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabFiles.png')}) no-repeat 0px -186px;*/
	}
	#CollabFileSharingModal .fileSharingList .sharingSettings {
		display: none;
		border: 1px solid #d4dadc;
		position: absolute;
		float: left;
		right: 28px;
		top: 102px;
		background-color: white;
		box-shadow: 0 2px 5px #acacac;
		padding-top: 9px;
		padding-bottom: 9px;
		padding-right: 4px;
		padding-left: 4px;
		padding: 5px;
		border-radius: 5px !important;
	}
	#CollabFileSharingModal .fileSharingList .sharingSettings.active {
		display: block;
	}
	#CollabFileSharingModal .fileSharingList .sharingSettings > div {
		display: block;
		width: 104px;
		border-radius: 7px !important;
		clear: both;
		padding: 4px 10px;
	}
	#CollabFileSharingModal .fileSharingHeader + div {
		border: solid 1px gray;
		float: left;
		border-top: 0px;
		width: 100%;
	}
	#CollabFileSharingModal .fileSharingHeader > li:first-child {
		width: 80%;
		border-right: 0px;
		padding-left: 5px;
	}
	#CollabFileSharingModal .fileSharingHeader > li:first-child + li {
		width: 20%;
		padding-left: 5px;
	}
	#CollabFileSharingModal .fileSharingHeader > li {
		float: left;
		border-bottom: 0px;
		border: solid 1px gray;
		list-style: none;
	}
	#CollabFileSharingModal .fileSharingList > li:first-child {
		border: 0px;
	}
	#CollabFileSharingModal .fileSharingList > li {
		border-top: solid 1px gray;
		display: block;
		padding: 3px;
		height: 37px;
		width: 100%;
		clear: both;
		list-style: none;
	}
	#CollabFileSharingModal .fileSharingList > li > div:first-child {
		margin-right: 5px;
	}
	#CollabFileSharingModal .fileSharingList > li > div:first-child + div {
		padding-top: 7px;
		width: 69%;
	}
	#CollabFileSharingModal .fileSharingList > li > div:first-child + div + div {
		padding-left: 40px;
		padding-top: 7px;
		width: 25%;
	}
	#CollabFileSharingModal .fileSharingList * {
		float: left;
	}
	#CollabFileSharingModal .fileSharingList > li > div.orgPhoto:first-child,
	#CollabFileSharingModal .fileSharingList > li > div:first-child > a > img,
	#CollabFileSharingModal .fileSharingList > li > div:first-child > img {
		height: 30px;
		width: 30px;
	}
	#CollabFileSharingModal .fileSharingList > li > div.orgPhoto {
		padding-right: 15px;
		padding-left: 15px;
		padding-top: 5px;
		padding-bottom: 10px;
		/*background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabCompanyShare.png')}) no-repeat 0px 0px;*/
	}
	#CollabFileSharingModal .fileSharingList > li > div > a.record {
		padding-right: 15px;
		padding-left: 15px;
		padding-top: 5px;
		padding-bottom: 10px;
		height: 30px;
		width: 30px;
		/*background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabRecordSprite.png')}) no-repeat 0px 0px;*/
	}
	#CollabFileSharingModal .fileSharingList > li .shareAnchor + a,
	#CollabFileSharingModal .fileSharingList > li .sharingStatus + a {
		display: block;
		height: 16px;
		width: 16px;
		float: right;
		/*background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabFollowSprite.png')}) no-repeat 0px -54px;*/
	}
	#CollabFileSharingModal .fileSharingList > li .shareAnchor + a:hover,
	#CollabFileSharingModal .fileSharingList > li .shareAnchor + a:focus,
	#CollabFileSharingModal .fileSharingList > li .shareAnchor + a:active,
	#CollabFileSharingModal .fileSharingList > li .sharingStatus + a:hover,
	#CollabFileSharingModal .fileSharingList > li .sharingStatus + a:focus,
	#CollabFileSharingModal .fileSharingList > li .sharingStatus + a:active {
		/*background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabFollowSprite.png')}) no-repeat 0px -75px;*/
	}
	#CollabFileUploadModal > div {
		padding: 10px;
	}
	#CollabFileUploadModal > div > div > select {
		margin-bottom: 10px;
		margin-left: 78px;
	}
	#CollabFileUploadModal > div > div > div {
		float: left;
	}
	#CollabFileUploadModal > div > div > div:first-child {
		padding-top: 42px;
		padding-right: 5px;
	}
	#CollabFileUploadModal > div > div > div > textarea {
		resize: none;
		width: 300px;
		height: 100px;
	}
	#CollabFileUploadModal > div > form {
		clear: both;
		margin-top: 10px;
	}
	#NewUserLinkModal > div,
	#NewGroupLinkModal > div {
		float: left;
		margin: 10px;
		margin-top: 30px;
	}
	#NewUserLinkModal #UserSearchInput,
	#NewGroupLinkModal #GroupSearchInput {
		border-left: none;
	}
	#NewUserLinkModal .select2-container,
	#NewGroupLinkModal .select2-container {
		padding: 5px;
		padding-left: 0px;
	}
	#NewUserLinkModal .hiddenDiv.select2-search,
	#NewGroupLinkModal .hiddenDiv.select2-search {
		display: none;
		border-right: 1px solid #aaa;
		border-left: 1px solid #aaa;
		border-bottom: 1px solid #aaa;
		padding-right: 0px;
		margin-top: -6px;
		padding-left: 0px;
		background: #fff;
	}
	#NewUserLinkModal .hiddenDiv.select2-search > input,
	#NewGroupLinkModal .hiddenDiv.select2-search > input {
		border-right: 0px;
		border-left: 0px;
	}
	#NewUserLinkModal .hiddenDiv.active,
	#NewGroupLinkModal .hiddenDiv.active {
		display: block;
	}
	#NewUserLinkModal > #NewUsers,
	#NewGroupLinkModal > #NewGroups {
		width: 600px;
		padding: 10px;
		float: left;
	}
	#NewUserLinkModal > #NewUsers > .newUser,
	#NewGroupLinkModal > #NewGroups > .newGroup {
		width: 100%;
		border: 1px solid #e0e3e5;
		border-top: none;
		float: left;
	}
	#NewUserLinkModal > #NewUsers > .newUsersHeader,
	#NewGroupLinkModal > #NewGroups > .newGroupsHeader {
		background: #f2f3f3;
		border: 1px solid #e0e3e5;
		float: left;
		width: 580px;
	}
	#NewUserLinkModal > #NewUsers > .newUsersFooter,
	#NewGroupLinkModal > #NewGroups > .newGroupsFooter {
		position: relative;
		float: left;
		width: 580px;
	}
	#NewUserLinkModal > #NewUsers > .newUsersFooter > div.select2-container,
	#NewGroupLinkModal > #NewGroups > .newGroupsFooter > div.select2-container {
		position:absolute;
		top: 0px;
		left: 0px;
	}
	#NewUserLinkModal > #NewUsers > .newUsersFooter > div.select2-container .select2-results,
	#NewGroupLinkModal > #NewGroups > .newGroupsFooter > div.select2-container .select2-results {
		max-height: 110px;
		margin-right: 0px;
		margin-top: 1px;
	}
	#NewUserLinkModal > #NewUsers > .newUser input,
	#NewGroupLinkModal > #NewGroups > .newGroup input {
		margin-left: 64px;
		margin-top: 11px;
	}
	#NewUserLinkModal > #NewUsers > .newUser div.actorDiv,
	#NewGroupLinkModal > #NewGroups > .newGroup div.actorDiv,
	#NewUserLinkModal > #NewUsers > .newUser div.actorDiv > div,
	#NewGroupLinkModal > #NewGroups > .newGroup div.actorDiv > div {
		padding-top: 10px;
		width: auto;
	}
	#NewUserLinkModal > #NewUsers > .newUser div,
	#NewUserLinkModal > #NewUsers > .newUsersHeader div,
	#NewGroupLinkModal > #NewGroups > .newGroup div,
	#NewGroupLinkModal > #NewGroups > .newGroupsHeader div {
		float: left;
		width: 130px;
	}
	#NewUserLinkModal > #NewUsers > .newUsersHeader > div.viewer,
	#NewGroupLinkModal > #NewGroups > .newGroupsHeader > div.viewer {
		padding-left: 50px;
	}
	#NewUserLinkModal > #NewUsers > .newUsersHeader > div.collaborator,
	#NewGroupLinkModal > #NewGroups > .newGroupsHeader > div.collaborator {
		padding-left: 30px;
	}
	#NewUserLinkModal > #NewUsers > .newUser > div:first-child,
	#NewGroupLinkModal > #NewGroups > .newGroup > div:first-child {
		width: 100%;
	}
	#NewUserLinkModal > #NewUsers > .newUser > div.fullDiv:first-child,
	#NewGroupLinkModal > #NewGroups > .newGroup > div.fullDiv:first-child {
		width: 100%;
	}
	#NewUserLinkModal > #NewUsers > .newUsersHeader > div:first-child,
	#NewGroupLinkModal > #NewGroups > .newGroupsHeader > div:first-child {
		width: 300px;
		padding-left: 5px;
	}
	#NewUserLinkModal > #NewUsers > .newUser > div > div.closeModal,
	#NewGroupLinkModal > #NewGroups > .newGroup > div > div.closeModal {
		float: right;
		width: 16px;
		height: 16px;
		margin-top: 10px;
		margin-right: 5px;
	}
	#NewUserLinkModal > #NewUsers > .newUser > div > div.closeModal > a,
	#NewGroupLinkModal > #NewGroups > .newGroup > div > div.closeModal > a {
		height: 16px;
		display: block;
		/*background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabFollowSprite.png')}) no-repeat 0px -54px;*/
	}
	/*
	#NewUserLinkModal > #NewUsers > .newUser > div > div.closeModal > a:hover,
	#NewUserLinkModal > #NewUsers > .newUser > div > div.closeModal > a:focus,
	#NewUserLinkModal > #NewUsers > .newUser > div > div.closeModal > a:active,
	#NewGroupLinkModal > #NewGroups > .newGroup > div > div.closeModal > a:hover,
	#NewGroupLinkModal > #NewGroups > .newGroup > div > div.closeModal > a:focus,
	#NewGroupLinkModal > #NewGroups > .newGroup > div > div.closeModal > a:active {
		background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabFollowSprite.png')}) no-repeat 0px -75px;
	}*/
	#NewUserLinkModal > #NewUsers > .newUser > div > div > div > span,
	#NewGroupLinkModal > #NewGroups > .newGroup > div > div > div > span {
		display: block;
		overflow: hidden;
		text-overflow: ellipsis;
		white-space: nowrap;
	}
	#NewUserLinkModal > #NewUsers > .newUser > div > div > img,
	#NewGroupLinkModal > #NewGroups > .newGroup > div > div > img {
		width: 30px;
		height: 30px;
		margin: 3px;
		border: 1px solid #e0e3e5;
		float: left;
	}
	#NewUserLinkModal .optionalMessage,
	#NewGroupLinkModal .optionalMessage {
		resize: none;
		width: 580px;
		overflow: hidden;
		color: gray;
	}
	#NewUserLinkModal .optionalMessage.active,
	#NewGroupLinkModal .optionalMessage.active {
		color: black;
	}
	#UserSearchAnchor,
	#GroupSearchAnchor {
		margin-bottom: 5px;
	}#CollabPreviewModal {
        position: relative;
        height: 511px !important;
    }
    #CollabFilesPreviewModal > div {
        position: relative;
        height: 480px;
        width: 640px;
        padding: 0px;
    }
    #CollabFilesPreviewModal > span,
    #CollabFilesPreviewModal > span > p {
        position: relative;
        width: 641px !important;
    }
    #UploadNewVersion {
        margin-bottom: 5px;
    }
    #UploadNewVersion > div {
        padding: 5px;
    }
    #UploadNewVersion > div > div:first-child + div {
        float: left;
        width: 100%;
        padding-top: 10px;
    }
    #UploadNewVersion > div > div:first-child + div > span {
        float: left;
    }
    #UploadNewVersion > div > div:first-child + div > textarea {
        resize: none;
        display: block;
        float: left;
        height: 54px;
        width: 100%;
    }
    #UploadNewVersion > div > input {
        margin-top: 5px;    
        float: right;
    }
    #EditFileDescriptionModal > div {
        padding: 10px;
        float: left;
        width: 100%;
    }
    #EditFileDescriptionModal textarea {
        resize: none;
        width: 100%;
        height: 100px;
    }
    #EditFileDescriptionModal input {
        margin-top: 10px;
        float: right;    
    }
	
	/* Collab Count Styles */
	.profile{
		text-align: center;
		padding-bottom: 15px;
	}
	.profilePicture {
		width: 90px;
	}
	.profile .centercls {
		font-size: 16px;
		text-transform: capitalize;
		padding: 5px 0px;
	}
	.count{
		color: #428BCA !important;
		border-bottom: 1px solid #DCDCDC;
	}
	.collabName {
		font-size: 14px;
		color: #848484;
	}
	.collabCountContainer .col-md-12 {
		min-height: 100px;
	}
		
	/* Collab Community Users Styles */
	/*
	.collabCommunityUsers * {
		font-size: 1em;
	}*/
	.collabCommunityUsers {
		float: left;
		width: 100%;
		min-height: 400px;
		/* max-height: 600px; */
		/* overflow-y:auto; */
	}
	.externalFlag {
		position: absolute;
		height: 20px;
		/*background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabAvatarSprite.png')}) no-repeat 0px 0px;*/
	}
	.communityUsersTableBackground {
		float: left;
		min-width: 651px;
		min-height: 400px;
		width: 100%;
	}
	.collabCommunityUsers > div:first-child #CommunityUsersSearchCancelButton {
		position: absolute;
		top: 12px;
		right: 15px;
	}
	.collabCommunityUsers > div:first-child #CommunityUsersSearchButton {
		position: absolute;
		top: 12px;
		right: 89px;
	}
	.collabCommunityUsers > div:first-child input.searchCollabCommunityUsers {
		position: absolute;
		right: 174px;
		top: 15px;
		color: #Ccc;
	}
	.collabCommunityUsers > div:first-child input.searchCollabCommunityUsers.textFieldActive{
		color:#000;
	}
	.collabCommunityUsers > div:first-child + div {
		float: left;
		//padding-left: 5px;
		//padding-right: 5px;
		//padding-top:20px;
	}
	.collabCommunityUsers .relativePanel {
		vertical-align: top;
		position: relative;
		display: inline-block;
	}
	.collabCommunityUsers > div:first-child > div {
		position: relative;
	}
	/*
	.collabCommunityUsers > div:first-child {
		margin-bottom: 20px;
	}*/
	.collabCommunityUsers > div:first-child,
	.collabCommunityUsers > div:first-child div {
		float: left;
		width: 100%;
		padding-top: 0px !important;
		padding-bottom: 0px !important;
	}
	.collabCommunityUsers > div:first-child h2 {
		float: left;
	}
	.collabCommunityUsers > div:first-child + div > div {
		width: 140px;
		float: left;
		padding-left: 5px;
		padding-right: 5px;
		padding-bottom: 20px;
		position: relative;
	}
	.collabCommunityUsers > div + div > div > .tabColor {
		padding-right: 25px;
	}
	.collabCommunityUsers .collabCommunityUsersButton {
		position: absolute;
		top: 33px;
		right: 20px;
		height: 16px;
		width: 16px;
		/*background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabFollowSprite.png')}) no-repeat 0px 0px;*/
	}
	.collabCommunityUsers .collabCommunityUsersButton.following {
		background-position: 0px -27px;
	}
	.collabCommunityUsers .collabCommunityUsersButton.following:active,
	.collabCommunityUsers .collabCommunityUsersButton.following:hover,
	.collabCommunityUsers .collabCommunityUsersButton.following:focus {
		background-position: 0px -54px;
	}
	/*
	.collabCommunityUsers > .collabCommunityUsersWrapper > .panel-default > .communityUsersInfo.panel-heading {
		border-radius: 0px !important;
	}
	.collabCommunityUsers .communityUsersInfo.panel-heading > div {
		overflow: hidden;
		text-overflow: ellipsis;
		white-space: nowrap;
		height: 16px;
	}*/
	.collabCommunityUsers .communityUsersImage {
		width: 80px;
		height: 80px;
		margin-right: 15px;
	}
	/*
	.collabCommunityUsers a.collabCommunityUsersButton:focus,
	.collabCommunityUsers a.collabCommunityUsersButton:active,
	.collabCommunityUsers a:hover > .communityUsersImage,
	.collabCommunityUsers a:focus > .communityUsersImage,
	.collabCommunityUsers a:active > .communityUsersImage {
		outline: 1px auto;
		outline-style: solid;
	}*/
	.collabCommunityUsers .communityUsersHeader {
		margin-bottom: 0px;
		cursor: default;
		text-overflow: ellipsis;
		overflow: hidden;
		white-space: nowrap;
	}
	.collabCommunityUsers .join,
	.collabCommunityUsers .leave {
		float: left;
	}
	/*
	.collabCommunityUsers > .panel-default > .panel-heading {
		float: left;
		width: 100%;
	}
	.collabCommunityUsers > .panel-default > .panel-heading > div {
		float: left;
		clear: left;
	}*/
	.loadingCollabCommunityUsers {
		float: left;
		clear: both;
		display: none;
		width: 170px;
		height: 170px;
		margin-left: 270px;
		margin-top: 25px;
		/*background: transparent url({!urlfor($Resource.GovGrantsExternal, 'Feedback/css/ajax-loader.gif')}) no-repeat 0px 0px;*/
	}
	.loadingCollabCommunityUsers.active{
		display: block;
	}
	.communityUsersInfo{
		display: inline-block;
	}
	/* UI-Shrawan-10202015 */
	.collabCommunityUsers .container-fluid {
		width: 100%;
		display: inline-block;
	}
	.collabCommunityUsers .container-fluid input{
		margin: 5px 5px;
		float: right;
	}
	.collabCommunityUsers .panel-body{
		overflow-y: auto;
	}
	.contentWrapper {
		margin: 5px 0px;
		padding: 10px 0px;
		border-bottom: 1px solid #DCDCDC;
	}
		
	/* Collab Colleagues Styles */
	/*
	.collabColleagues * {
		font-size: 1em;
	}*/
	.collabColleagues {
		float: left;
		width: 100%;
		min-height: 400px;
		/* max-height: 600px; */
		/* overflow-y:auto; */
	}
	.colleaguesTableBackground {
		float: left;
		min-width: 651px;
		min-height: 400px;
		width: 100%;
	}
	.collabColleagues > div:first-child #ColleaguesSearchCancelButton {
		position: absolute;
		top: 12px;
		right: 15px;
	}
	.collabColleagues > div:first-child #ColleaguesSearchButton {
		position: absolute;
		top: 12px;
		right: 89px;
	}
	.collabColleagues > div:first-child input.searchCollabColleagues {
		position: absolute;
		right: 174px;
		top: 15px;
		color: #ccc;
	}
	.collabColleagues > div:first-child input.searchCollabColleagues.textFieldActive{
		color:#000;
	}
	/*
	.collabColleagues > div:first-child + div {
		float: left;
		padding-left: 5px;
		padding-right: 5px;
		padding-top: 17px;
	}*/
	.collabColleagues > div:first-child > div {
		position: relative;
	}
	/*
	.collabColleagues > div:first-child {
		margin-bottom: 20px;
	}*/
	.collabColleagues > div:first-child,
	.collabColleagues > div:first-child div {
		float: left;
		width: 100%;
		padding-top: 0px !important;
		padding-bottom: 0px !important;
	}
	.collabColleagues > div:first-child h2 {
		float: left;
	}
	/*
	.collabColleagues > div:first-child + div > div {
		/*width: 140px;*//*
		float: left;
		padding-left: 5px;
		padding-right: 5px;
		padding-bottom: 20px;
		position: relative;
	}*/
	.collabColleagues > div + div > div > .tabColor {
		padding-right: 25px;
	}
	.collabColleagues .collabColleaguesButton {
		position: absolute;
		top: 33px;
		right: 20px;
		height: 16px;
		width: 16px;
		/*background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabFollowSprite.png')}) no-repeat 0px 0px;*/
	}
	.collabColleagues .collabColleaguesButton.following {
		background-position: 0px -27px;
	}
	.collabColleagues .collabColleaguesButton.following:active,
	.collabColleagues .collabColleaguesButton.following:hover,
	.collabColleagues .collabColleaguesButton.following:focus {
		background-position: 0px -54px;
	}
	/*  UI-Shrawan  10192015
	.collabColleagues > .collabColleaguesWrapper > .panel-default > .colleaguesInfo.panel-heading {
		border-radius: 0px !important;
	}
	.collabColleagues .colleaguesInfo.panel-heading > div {
		overflow: hidden;
		text-overflow: ellipsis;
		white-space: nowrap;
		height: 16px;
	}
	*/
	.collabColleagues .colleaguesImage {
		width: 80px;
		height: 80px;
		margin-right: 15px;
	}
	/*
	.collabColleagues a.collabColleaguesButton:focus,
	.collabColleagues a.collabColleaguesButton:active,
	.collabColleagues a:hover > .colleaguesImage,
	.collabColleagues a:focus > .colleaguesImage,
	.collabColleagues a:active > .colleaguesImage {
		outline: 1px auto;
		outline-style: solid;
	}
	*/
	.collabColleagues .colleaguesHeader {
		margin-bottom: 0px;
		cursor: default;
		text-overflow: ellipsis;
		overflow: hidden;
		white-space: nowrap;
		display: inline-block;
	}
	.collabColleagues .join,
	.collabColleagues .leave {
		float: left;
	}
	/*
	.collabColleagues > .panel-default > .panel-heading {
		float: left;
		width: 100%;
	}
	.collabColleagues > .panel-default > .panel-heading > div {
		float: left;
		clear: left;
	}
	*/
	.loadingCollabColleagues {
		float: left;
		clear: both;
		display: none;
		width: 170px;
		height: 170px;
		margin-left: 270px;
		margin-top: 25px;
		/*background: transparent url({!urlfor($Resource.GovGrantsExternal, 'Feedback/css/ajax-loader.gif')}) no-repeat 0px 0px;*/
	}
	.loadingCollabColleagues.active{
		display: block;
	}
	.contentWrapper {
		margin: 5px 0px;
		padding: 10px 0px;
		border-bottom: 1px solid #DCDCDC;
	}
	.collabColleagues .container-fluid {
		width: 100%;
		display: inline-block;
	}
	.collabColleagues .container-fluid input{
		margin: 5px 5px;
		float: right;
	}
	.collabColleagues .panel-body{
		overflow-y: auto;
	}
	.colleaguesInfo {
		display: inline-block;
	}
	.colleaguesInfo p{
		margin: 2px 0px;
	}
	/* Collab Page Styles */
	.bs .collabComponent a,
	.bs a.darkAnchor {
		color: #0068B6;
	}
	a.solid:focus,
	a.solid:active,
	.collabModal > a:focus,
	.collabModal > a:active {
		outline: 1px auto;
		outline-width: thin !important;
		outline-style: solid !important;
	}
	input[type="button"]:focus,
	input[type="button"]:active,
	.collabComponent a:focus > img,
	.collabComponent a:active > img {
		outline: #0080FF;
		outline-width: thin !important;
		outline-style: solid !important;
	}
   
	@media (min-width: 768px) {
		.componentWrapper {
			overflow: hidden;
			float: none;
		}
	}
	@media (max-width: 768px) {
		.componentWrapper {
			float: left;
			overflow: visible;
		}
		#CollabMenu {
			width: 100%;
			max-width: 768px;
		}
	}
	
	#sidebarToggleContainer.collabSidebarToggleContainer.sidebarToggleContainer {
		float: left;
		position: relative;
		display: block;
		top: -57px;
		left: 4px !important;
		height: 237px;
	}
	.collabSidebarToggleContainer.sidebarToggleContainer > span {
		float: left;
		display: block;
	}
	.collabComponent {
		display: none;
	}
	.collabComponent.active {
		display: block;
	}
	.collabHiddenDiv > span {
		text-indent: -99999px;
	}
	#CollabFiles .list.dataTable {
		width: 100% !important;
	}
	#CollabFiles .collabFilesWrapper > .panel.panel-default > .panel-heading,
	#CollabTopics .collabTopics > .panel.panel-default > .panel-heading {
		margin-bottom: 20px;
	}
	#CollabFiles .collabFilesWrapper > .panel.panel-default > .panel-body,
	#CollabTopics .collabTopics > .panel.panel-default > .panel-body {
		padding-bottom: 25px;
	}
	.collabSidebarToggleContainer.open > .indicator {
		background: url(https://gg1.na11.visual.force.com/img/alohaSkin/sidebar_sprite.png) 0px 0px no-repeat !important;
	}
	.collabSidebarToggleContainer > .indicator {
		background: url(https://gg1.na11.visual.force.com/img/alohaSkin/sidebar_sprite.png) 0px -62px no-repeat !important;
	}
	.leftbar {
		width:100%;
		display:block;
		margin-left:30px;
		margin-top:15px;
		margin-bottom:5px;
	}   
	.top-right-margin {
		margin-top:10px;
		margin-right:10px;
	}
	
	.list-nostyle {
		list-style-type: none ;
	}   
	 
   .centercls{  
		margin-left: auto;
		margin-right: auto;
		display: block;
	}
  
	.topSidebarMenu {    
		min-height: 951px;
		background-color: #EEF1F7;
		/*margin-left: -14px!important;*/
		/*margin-right: 0px;*/
		display: inline-block;
		width: 100%;
	}
	.topSidebarMenu .ul {    
		width: 100%;
		margin-left: -10px;
	}
	.headermenu {
		background-color:#EEF1F7;
	}   
	/* UI-Shrawan-10202015 */
	.collabMenuOption  {
		border-bottom: 1px solid #CFD6E6;
	}
	.collabMenuOption.active {
		background-color: #CFD6E6;
	}
	.collabMenuOption.active > a{
		color: #2a6496;
		text-decoration: underline;
	} 
	.collabSubMenuOptions{
		background-color: #FFFFFF;
	}
		
/* Collab Component Styles */
    .displayinline {
        display:inline-block;
        width:100%;
    }
        
    .media { width: 100%; }
    .media-heading { font-weight: bold !important; }
    
    .collabFeedWrapper > div.feedItem.firstColor {
        padding-left: 50px;
    }
    .collabFeedWrapper > div.feedItem .singleComment.firstColor,
    .collabFeedWrapper > div.feedItem .createCollabComment.firstColor {
        padding-left: 40px;
    }
    .collabFeedWrapper > div.feedItem .singleComment.secondColor {
        padding-right: 40px;
    }
    .collabFeedWrapper > div.feedItem.secondColor {
        padding-right: 50px;
    }
    .firstColor > .initialPost,
    .firstColor > .initialComment { 
        background-color: #E2F5FC; 
    }
    .secondColor > .initialPost,
    .secondColor > .initialComment { 
        background-color: #EEF1F7; 
    }
    .initialPost,
    .initialComment {
        display: inline-block;
        padding: 10px;
        border-radius: 10px;
        overflow: visible;
        width: 100%;
        margin: 0 !important;
    }
        
    media-body {
        display: inline-block;
        width: 100%;
        padding: 5px 5px;
        border-radius:5px;
        overflow: hidden;
        margin: 0 auto;
    }

    @media (min-width: 200px) {
        .collabFeedWrapper > .feedItem .collabFeedItemMenu {
            right: 10px;
        }
    }
    @media (max-width: 800px) {
        .collabFeedWrapper > .feedItem .collabFeedItemMenu {
            /*right: 0px;*/
        }
    }
    textarea, input {
        overflow: hidden;
    }
    .hiddenPanel {
        display: none;
    }
    /*
    .collabTableBackground * {
        font-size: 1em;
    }*/
    .collabTableBackground {
        /*float: left;*/
        width: 100%;
        //margin-bottom: 25px;
    }
    .collabTableBackground > div {
        /*float: left;*/
        width: 100%;
    }
    .collabTableBackground a{
        color: rgb(66, 139, 202);
    }
    .collabTableBackground .customBtn:disabled,
    #CollabShareModal .customBtn:disabled {
        cursor: default;
    }
    .collabPanel {
        /*float: left;*/
    }
    .collabModal {
        display: none;
    }
    .collabModal.active {
        display: block;
    }
    .collabPanel > div:first-child {
        position: relative;
    }
    .collabPanel > div:first-child,
    .collabPanel > div:first-child div {
        /*float: left;*/
        width: 100%;
        padding-top: 0px !important;
        padding-bottom: 0px !important;
    }
    .collabPanel > div:first-child #CollabSearchCancelButton {
        position: absolute;
        top: 5px;
        right: 35px;
    }
    .collabPanel > div:first-child #CollabSearchButton {
        position: absolute;
        top: 5px;
        right: 109px;
    }
    .collabPanel > div:first-child #CollapseFeedAnchor {
        position: absolute;
        top: 5px;
        right: 6px;
        font-size: 20px;
    }
    .collabPanel > div:first-child #CollapseFeedAnchor:hover {
        cursor: pointer;
    }
    .collabPanel > div:first-child #CollapseFeedAnchor:hover,
    .collabPanel > div:first-child #CollapseFeedAnchor:focus,
    .collabPanel > div:first-child #CollapseFeedAnchor:active {
        text-decoration: none;
    }
    .collabPanel > div:first-child input.searchCollabFeeds {
        position: absolute;
        right: 194px;
        top: 8px;
            color: #ccc;
    }
    .collabPanel > div:first-child input.searchCollabFeeds.textFieldActive{
        color:#000;
    }
    .collabPanel > div:first-child h2 {
        /*float: left;*/
    }
    #collabContainer {
        /*float:left;*/
        background-color: #FFF;
        //padding: 20px;
        clear: both;
        /*padding-bottom: 50px;*/
    }
    .publisherShareButton {
        float: right;
        margin-top: 12px !important;
    }
    .collabFeedWrapper > .feedItem {
        display: none !important;
    }
    .collabFeedWrapper {
    /*display: none;*/
        
        // changes made
            width: 100%;
    height: 470px;
  //  max-width: 540px;
    overflow-y: auto;
    overflow-x:hidden;
    border: 1px solid #c8c8c8;
       

    }
    .collabFeedWrapper.active > .feedItem{
        display: block !important;
    }
    .loadingNewPost,
    .loadingCollabFeed {
        clear: both;
        display: none;
        height: 32px;
    /*margin-left: 254px;*/
        margin-top: 25px;
        padding-bottom: 70px;
        /*background: transparent url({!urlfor($Resource.GovGrantsExternal, 'Feedback/css/ajax-loader.gif')}) no-repeat 50% 0px;*/
    }
    .loadingNewPost.active,
    .loadingCollabFeed.active {
        display: block;
    }
    .loadingNewPost.active.inactive,
    .loadingCollabFeed.active.inactive {
        display: none;
    }
    .collabWrapper {
      /*  max-width: 540px;*/
        width: 100%;
        /*float: left;*/
        clear:both;
        padding-bottom: 10px;
        //padding: 0px 10px 5px 10px;
        position: relative;
    }
    .collabWrapper > div,
    .collabWrapper > ul,
    .collabWrapper > form{
        /*float:left;*/
        clear:both;
        width:100%;
        margin:0px !important;
        padding:0px !important;
        display:block;
        position: relative;
    }
    .collabWrapper > ul{
        z-index: 5;
    }
    .collabWrapper > ul li{
        font-weight:bold;
        display:block;
        /*float: left;*/
        display: inline-block;
        padding-right:13px;
    }
    .collabWrapper > ul li.carrot {
        padding-bottom: 14px;
        position: relative;
    }
    .collabWrapper > ul li.carrot > span {
        position: absolute;
        bottom: 1px;
        width: 23px;
        height: 16px;
        left: 15px;
        display: block;
        /*background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabCarrots.png')}) no-repeat -48px 3px;*/
    }
	/*
    .collabWrapper.orange > ul li.carrot > span {
        background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabCarrots.png')}) no-repeat -93px 3px;
    }*/
    .collabWrapper > ul li a,
    .collabFeedWrapper .linkBlock > a{
        padding:1px 1px 1px 21px;
        line-height: 16px;
        height:16px;
    }
    #CollabFile {
        height: 22px;
    }
    
    /*Background might not be white*/
    /*.collabFeedWrapper .linkBlock > a{background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabSprites.png')}) no-repeat 0px -1102px;}
    .collabWrapper > ul li a.post{background: #fff url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabSprites.png')}) no-repeat 0 -1182px;}
    .collabWrapper > ul li a.link{background: #fff url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabSprites.png')}) no-repeat 0 -1042px;}
    .collabWrapper > ul li a.file{background: #fff url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabSprites.png')}) no-repeat 0 -1022px;}
    */
    .collabWrapper > ul li a:hover,
    .collabWrapper > ul li a:active,
    .collabWrapper > ul li a:focus{
        text-decoration: underline;
    }
    .collabFeedWrapper .showMore > a {
        color: #7B667B;
        padding-left: 19px;
        /*background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabSprites.png')}) no-repeat 0px -422px;*/
    }
    .collabFeedWrapper .showMore > a:active,
    .collabFeedWrapper .showMore > a:focus,
    .collabFeedWrapper .showMore > a:hover {
        color: #015ba7;
    }
    .collabFeedWrapper .collabLike > span {
        padding-left: 19px;
        line-height: 14px;
        /*background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabSprites.png')}) no-repeat 0px -524px;*/
    }
    .collabWrapper > ul li a.active {
        color:#393939;
    }
    .collabWrapper > div {
        display:none;
        position: relative;
    }
    #CollabPostBottomBar {
        display: block;
        height: 55px;
    }
    .collabWrapper > div.active {
        display:block;
        padding-bottom: 20px;
    }
    .collabWrapper > div.post,
    .collabWrapper > div.link,
    .collabWrapper > div.file{
        z-index: 1;
        margin-top:-2px !important;
        cursor: default;
        position:relative;
    }
    .collabWrapper > div.file .collabUploadOptions {
        height: 63px !important;
    }
    .collabWrapper > div.post > div:first-child,
    .collabWrapper > div.link > div:first-child + div,
    .collabWrapper > div.file .collabUploadOptions + div,
    .collabWrapper > div.file .collabUploadOptions,
    .collabWrapper > div.link > div:first-child,
    #CollabShareModal div.share > div:first-child{
        width: auto;
        height: auto;
        background-color: #fff;
        background-repeat: repeat-x;
        position: relative;
        border: 1px solid #c7ccce;
        padding: 7px 7px 6px 7px;
        //border-top-left-radius: 3px !important;
        //border-top-right-radius: 3px !important;
        //border-bottom-left-radius: 3px !important;
        //border-bottom-right-radius: 3px !important;
        /*float:left;*/
        clear:both;
        width:100%;
    }
    #CollabShareModal .shareWithAnchor,
    .collabWrapper .postToAnchor {
        position: relative;
        padding-right: 11px;
    }
    #CollabShareModal .shareWithAnchor > span,
    .collabWrapper .postToAnchor > span {
        font-weight: normal !important;
        color: #015ba7;
    }
    #CollabShareModal .shareWithAnchor > span + span,
    .collabWrapper .postToAnchor > span + span {
        position: absolute;
        width: 7px;
        height: 8px;
        margin-top: 6px;
        right: 0px;
        /*background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabSprites.png')}) no-repeat 0px -1831px;*/
    }
    #CollabShareModal .shareWithAnchor:hover,
    #CollabShareModal .shareWithAnchor:focus,
    #CollabShareModal .shareWithAnchor:active,
    .collabWrapper .postToAnchor:hover,
    .collabWrapper .postToAnchor:focus,
    .collabWrapper .postToAnchor:active {
        font-weight: normal;
        text-decoration: none;
        color: #015ba7;
    }
    #CollabShareModal .postTo,
    .collabWrapper .postTo {
        /*float: left;*/
        display: none;
        width: auto;
        border: 1px solid #c7ccce;
        border-bottom: 0;
        position: absolute;
    }
    .collabWrapper .postTo {
        top: 12px;
        left: 16px;
    }
    #CollabShareModal .postTo {
        top: 8px;
        left: 15px;
    }
    #CollabShareModal .postTo *,
    .collabWrapper .postTo * {
        /*float: left;*/
        display: inline-block;
    }
    #CollabShareModal .postTo.active,
    .collabWrapper .postTo.active {
        display: block;
        z-index: 1;
    }
    #CollabShareModal .postTo > div,
    .collabWrapper .postTo > div {
        width: 100%;
        clear: both;
    }
    .collabWrapper .postTo > div:hover,
    .collabWrapper .postTo > div:active,
    .collabWrapper .postTo > div:focus {
        
    }
    #CollabShareModal .postTo > div > a,
    .collabWrapper .postTo > div > a {
        padding-top: 5px;
        padding-bottom: 5px;
        padding-left: 9px;
        padding-right: 9px;
        color: #015ba7;
        border-bottom: 1px solid #c7ccce;
        white-space: nowrap;
        width: 100%;
        background-color: #FFF;
    }
    #CollabShareModal .postTo > div > a:hover,
    #CollabShareModal .postTo > div > a:focus,
    #CollabShareModal .postTo > div > a:active,
    .collabWrapper .postTo > div > a:hover,
    .collabWrapper .postTo > div > a:focus,
    .collabWrapper .postTo > div > a:active {
        text-decoration: none; 
        background-color: #E2EFFD;
    }
    .collabWrapper > div.post > div:first-child,
    #CollabShareModal div.share {
       width:90%;
    }
    #CollabShareModal div.share > div:first-child + div > *{
        /*float: left;*/
    }
    #CollabShareModal .groupSelect,
    .collabWrapper .groupSelectMain {
        margin-left: 10px;
        display: none;
    }
    #CollabShareModal .groupSelect.active,
    .collabWrapper .groupSelectMain.active {
        display: inline;
    }
    #CollabShareModal .collabFeedItemMenu {
        display: none;
        right: 10px;
        top: 10px;
    }
    #CollabShareModal div.share {
        position: relative;
        /*float: left;*/
        margin-top: 30px;
    }
    #CollabShareModal div.share .carrot {
        position: absolute;
        width: 22px;
        top: -8px;
        left: 18px;
        /*background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabCarrots.png')}) no-repeat -48px 0px;*/
        padding-bottom:9px;
    }
    #CollabShareModal > span + div{
        width: 100%;
        /*float: left;*/
    }
    #CollabShareModal div.share > div:first-child + div + input{
        /*float: right;*/
        position: absolute;
        bottom: 7px;
        right: 0px;
        margin-bottom: 12px;
        margin-right: 10px;
    }
    .collabWrapper > div.post > div:first-child,
    .collabWrapper > div.link > div:first-child + div,
    .collabWrapper > div.file .collabUploadOptions + div,
    .collabWrapper > div.file .collabUploadOptions,
    .collabWrapper > div.link > div:first-child,
    #CollabShareModal div.share > div:first-child,
    #CollabShareModal div.share > div:first-child + div {
        border-bottom-left-radius: 0px !important;
        border-bottom-right-radius: 0px !important;
        /*float:left;*/
        clear:both;
        width:100%;
    }
    .collabWrapper.orange > div > div:first-child {
        border-right: #fe8b20 1px solid;
        border-left: #fe8b20 1px solid;
        border-top: #fe8b20 1px solid;
    }
    .collabWrapper.orange > div > div:first-child + div {
        border-right: #fe8b20 1px solid;
        border-left: #fe8b20 1px solid;
    }
    .collabWrapper.orange > #CollabPostBottomBar {
        border-right: #fe8b20 1px solid;
        border-left: #fe8b20 1px solid;
        border-bottom: #fe8b20 1px solid;
    }
    .collabWrapper > div.link > div:first-child + div,
    .collabWrapper > div.file .collabUploadOptions + div{
        border-top:none;
        border-top-left-radius: 0px !important;
        border-top-right-radius: 0px !important;
        /*float: left;*/
        clear:both;
        width:100%;
    }
    .collabWrapper > div.post > div:first-child textarea,
    .collabWrapper > div.link > div:first-child + div textarea,
    .collabWrapper > div.file .collabUploadOptions + div textarea,
    #CollabShareModal div.share > div:first-child textarea {
        color: #000;
        border: none;
        resize: none;
        width: 100%;
        overflow: hidden;
        background-color: #fff;
        line-height: 16px;
        -webkit-line-break: after-white-space;
        word-wrap: break-word;
        display: block;
        min-height: 48px;
    }
    .collabWrapper .postToSelectList {
        margin-top: 11px;
        border: 1px solid #dedede;
        border-radius: 5px !important;
    }

    /****** Switched focus from child items to divs directly in front of text areas ******/
    .collabWrapper > div.post > div:first-child.default textarea,
    .collabWrapper > div.link > div:first-child + div.default textarea,
    .collabWrapper > div.file .collabUploadOptions + div.default textarea {
        color:#716562;
    }
    .collabWrapper > div.post > div:first-child + div{
        display:none;
        position: relative;
    }
    .collabFeedWrapper .feedElementActionList > li,
    .collabFeedWrapper .commentActionList > li {
        display: none;
    }
    .collabFeedWrapper .feedElementActionList > li.active,
    .collabFeedWrapper .commentActionList > li.active {
        display: inline-block;
    }
    #CollabShareModal div.share > div:first-child + div {
        position: relative;
    }
    #CollabShareModal div.share > div:first-child + div {
        /*float: left;*/
    }
    #CollabShareModal div.share > div:first-child + div,
    #CollabPostBottomBar {
        display:block;
        padding: 9px;
        background: #f5f6f6;
        border: 1px solid #c7ccce;
        border-top: none;
        border-bottom-left-radius: 3px !important;
        border-bottom-right-radius: 3px !important;
        /*float:left;*/
        clear:both;
        width:100%;
        padding-left: 7px !important;
        padding-right: 7px !important;
    }
    #CollabPostBottomBar > span,
    #CollabPostBottomBar > .whoSee {
        /*float: left;*/
        display: inline-block;
    }
    #CollabPostBottomBar form {
        display: inline;
    }
    #CollabPostBottomBar > span:first-child {
        padding-left: 3px;
    }
    #CollabPostBottomBar > span {
        margin-top: 18px;
        margin-bottom: 18px;
    }
    .collabWrapper a.whoSee{
        display: inline-block;
        vertical-align: top;
        /*float: left;*/
        text-indent: -99999px;
        font-size: 1px;
        height:16px;
        width:16px;
        margin-top:18px;
        margin-left:10px;
        /*background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabSprites.png')}) no-repeat 0 -1242px;*/
    }
	/*
    .collabWrapper a.whoSee:active,
    .collabWrapper a.whoSee:hover,
    .collabWrapper a.whoSee:focus{
        background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabSprites.png')}) no-repeat 0 -1222px;
    }*/
    .collabWrapper div.whoSeeCarrot {
        display: none;
        width: 22px;
        height: 23px;
        position: absolute;
        bottom: 5px;
        left: 119px;
        z-index: 6;
        /*background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabCarrots.png')}) no-repeat -48px 0px;*/
    }
    .collabWrapper div.whoSeeCarrot.active {
        display: block;
    }
    .collabWrapper .whoSeeHiddenDiv {
        position: absolute;
        top: 142px;
        left: 100px;
        border: 1px solid #c1c1c1;
        background-color: #fff;
        border-radius: 5px !important;
        z-index: 5;
        width: 300px;
        box-shadow: 0 2px 5px #a0a6ab;
        display: none;
    }
    .collabWrapper .whoSeeHiddenDiv.active {
        display: block;
    }
    .collabWrapper .whoSeeHiddenDiv > div:first-child{
        display: block;
        clear: both;
        padding: 15px !important;
    }
    .collabWrapper .whoSeeHiddenDiv > div > h3 {
        font-size: 1em;
        font-weight: bold;
        margin: 0px;
        margin-bottom: 0px;
        margin-top: 10px;
    }
    .collabWrapper .whoSeeHiddenDiv > .whoSeeFooter {
        background-color: rgb(245, 246, 246);
        border-top-color: rgb(233, 234, 235);
        border-top-style: solid;
        border-top-width: 1px;
        color: rgb(34, 34, 34);
        display: block; 
        height: 30px;
        line-height: 30px;
        padding-left: 15px;
        border-radius: 0px 0px 5px 5px !important;
    }
    .collabWrapper > div.post > div:first-child + div span,
    .collabWrapper > div.link > div:first-child + div + div span,
    .collabWrapper > div.file .collabUploadOptions + div + div span,
    #CollabShareModal div.share > div:first-child + div span{
        display:block;
        /*float: left;*/
        margin-top:5px;
    }
    .collabWrapper > div.post > div:first-child + div span span,
    .collabWrapper > div.link > div:first-child + div + div span span,
    .collabWrapper > div.file .collabUploadOptions + div + div span span,
    #CollabShareModal div.share > div:first-child + div span span{
        display:inline;
        float:none;
        font-weight: bold;
    }
    #CollabShareModal div.share > div:first-child + div span a.postToAnchor span {
        font-weight: normal;
    }
    .collabWrapper > div.post > div:first-child + div  > input[type="button"],
    .collabWrapper > div.link > div:first-child + div + div  > input[type="button"],
    .collabWrapper > div.file .collabUploadOptions + div + div > input[type="submit"],
    #CollabShareModal div.share > div:first-child + div > input[type="button"] {
        margin:3px 0px;
        /*float: right;*/
    }

    .collabWrapper > div.link > div:first-child label{
        display: block;
        /*float: left;*/
        clear:both;
        width:70px;
        line-height: 31px;
        color: #4a4a56;
        font-weight: bold;
        margin-bottom:10px;
        font-size: 1em;
        text-indent: 0px;
    }
    .collabWrapper > div.link > div:first-child input[type="text"]{
        padding: 7px;
        border: 1px solid #c7ccce;
        border-top-left-radius: 3px !important;
        border-top-right-radius: 3px !important;
        border-bottom-left-radius: 3px !important;
        border-bottom-right-radius: 3px !important;
        background-image: url(/img/chatter/innershadow-normal.png);
        background-position: 0 0;
        width: 100%;
        max-width: 407px;
        height: auto;
        background-color: #fff;
        background-repeat: repeat-x;
        margin-bottom:10px;
    }

    .collabWrapper > div.file #collabLinkFileAction,
    .collabWrapper > div.file #collabUploadFileAction{
        margin-left: 5px;
        margin-right: 10px;
        text-decoration: none;
        color: #015ba7;
        display: block;
        border-top-left-radius: 5px !important;
        border-top-right-radius: 5px !important;
        border-bottom-left-radius: 5px !important;
        border-bottom-right-radius: 5px !important;
        border: 1px solid #c7ccce;
        padding: 15px 0;
        width: 45%;
        text-align: center;
    }
    .collabWrapper > div.file #collabLinkFileAction {
        /*float: left;*/
    }
    .collabWrapper > div.file #collabUploadFileAction {
        /*float: right;*/
    }
    .collabWrapper > div.file #collabLinkFileAction:hover,
    .collabWrapper > div.file #collabLinkFileAction:active,
    .collabWrapper > div.file #collabLinkFileAction:focus,
    .collabWrapper > div.file #collabUploadFileAction:hover,
    .collabWrapper > div.file #collabUploadFileAction:active
    .collabWrapper > div.file #collabUploadFileAction:focus{
        background-color: #f5f6f6;
        text-decoration: underline;
    }
    .collabWrapper > div.file #CollabClose{
        /*float: right;*/
        display:block;
        width: 20px;
        height: 20px;
        text-indent: -99999px;
        font-size: 1px;
        /*background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabXButtons.png')}) no-repeat 0px 0px;*/
    }
    .collabWrapper > div.file #CollabClose:hover,
    .collabWrapper > div.file #CollabClose:focus,
    .collabWrapper > div.file #CollabClose:active{
        background-position: left -20px;
    }
    .collabWrapper > div.file #CollabClose + div + div > div:first-child,
    .existingCommentFileDiv > div:first-child {
        width: 32px;
        height: 32px;
        /*float: left;*/
        /*background-image: url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabExtensionImages.png')});*/
    }
    .existingCommentFileDiv > div:first-child + div {
        /*float: left;*/
    }
    .existingCommentFileDiv > div:first-child + div > div:first-child {
        font-weight: bold;
    }
    .collabWrapper > div.file #CollabClose + div + div > div + div > div {
        font-weight: bold;
        padding-bottom: 5px;
    }
    #CollabShareModal .feedItem a,
    #CollabShareModal .feedItem a:hover {
        text-decoration: none;
        cursor: default;
    }
    .collabSortDropdown,
    .collabSearch {
        display:none;
    }
    .collabSearch.active,
    .collabSortDropdown.active {
        display: block;
    }
    .collabSortDropdown {
        position: relative;
        display: inline-block;
        /*float: left;*/
        clear: both;
        width: 100%;
        font-size: 1em;
        /*padding-bottom:  20px;*/
    }
    .collabSortDropdown .collabSearchOrder {
        /*float: left;*/
    }
    /*Uncomment for search box*/
/*     .collabSortDropdown > a:first-child:hover, */
/*     .collabSortDropdown > a:first-child:focus, */
/*     .collabSortDropdown > a:first-child:active { */
/*      background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabMagnifyingGlasses.png')}) no-repeat 0px -32px; */
/*      text-decoration: none; */
/*     } */
    /*Return to a + a for search box*/
    .collabSortDropdown > a:hover,
    .collabSortDropdown > a:focus,
    .collabSortDropdown > a:active {
        text-decoration: none;
        transition: all 0.2s ease-in-out 0.2s;
        background-color: #FBFBFB;
        box-shadow: 0px 1px 0px rgba(255, 255, 255, 0.5) inset;
        border: 1px solid #C1C1C1;
        border-radius: 3px !important;
        cursor: pointer;
    }
    /*Return to a + a for search box*/
    .collabSortDropdown > a:hover > span:first-child,
    .collabSortDropdown > a:focus > span:first-child,
    .collabSortDropdown > a:active > span:first-child {
        color: #222;
        border-color: #FFF;
        transition: all 0.2s ease-in-out 0.2s;
    }
    /*Return to a + a for search box*/
    .collabSortDropdown > a:hover > span + span,
    .collabSortDropdown > a:focus > span + span,
    .collabSortDropdown > a:active > span + span {
        color: #428BCA;
    }
    /*Uncomment for search box*/
/*     .collabSortDropdown > a:first-child {  */
/*      float:left;   */
/*      margin: 7px 9px 4px 1px; */
/*      height: 12px; */
/*      width: 12px; */
/*      line-height: 12px; */
/*      background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabMagnifyingGlasses.png')}) no-repeat 0px -16px; */
/*     } */
    .collabSearch > div {
        position: relative;
        width: 192px;
        padding-bottom: 20px;
    }
    .collabSearch > div > textarea {
        height: 31px;
        width: 100%;
        padding: 8px 35px 7px 25px;
        border: 1px solid #ccc;
        border-radius: 3px !important;
        resize: none;
        overflow: hidden;
        /*background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabSingleMagnifyingGlass.png')}) no-repeat scroll 3px 6px;*/
        box-shadow: 0 1px 1px #e7e7e8 inset;
    }
    .collabSearch > div > textarea + a {
        position: absolute;
        height: 16px;
        width: 16px;
        top: 9px;
        right: 10px;
        /*background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabCloseButtons.png')}) no-repeat 0px -16px;*/
    }
    /*Return to a + a for search box*/
    .collabSortDropdown > a {
        border: 1px solid #FFF;
        padding: 6px 12px 6px 6px;
        text-decoration: none;
        // margin-left: 7px;
        /*float: left;*/
    }
    /*Return to a + a for search box*/ 
    .collabSortDropdown > a > span {
        /*float: left;*/
    }
    .collabSortDropdown > a > #downArrow {
        /*float: left;*/
        display: inline-block;
        height: 8px;
        width: 8px;
        margin-left: 8px;
        margin-top: 3px;
        /*background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabSprites.png')}) no-repeat 0 -1838px;*/
    }
    /*Return to a + a for search box*/ 
    .collabSortDropdown > a > span:first-child {
        // padding-left: 12px;
        color: #015BA7;
        // border-left: solid 1px;
        border-color: #C1C1C1;
        color: #7B667B;
        margin-right: 5px; //UI-Shrawan-11052015
    }
    .collabSortDiv {
        display: none;
        position: absolute;
        top: 29px;
        //margin: 0px;
        max-height: 450px;
        overflow-y: auto;
        //margin-top: 5px;
        //margin-left: 3px;
        background: none repeat scroll 0px 0px rgba(255, 255, 255, 0.95);
        border: 1px solid #CCC;
        border-radius: 3px !important;
        left: 26px;
        list-style: outside none none;
        overflow: hidden;
        width: 190px;
        z-index: 1000;
        box-shadow: 0px 0px 2px #ECECEC;
        transition: all 0.2s ease-in-out 0.2s;
    }
    .collabSortDiv.active {
        display: block;
    }
    .collabSortDiv > div:first-child {
        color: #8B8B8B;
        display: block;
        //font-size: 0.9em;
        font-weight: normal;
        padding: 8px 0px 5px 25px;
    }
    .collabSortDiv > div {
        /*float: left;*/
        clear: both;
        width: 100%;
    }
    .collabSortDiv > div > a {
        /*float: left;*/
        display: block;
        font-weight: normal;
        text-align: left;
        text-decoration: none;
        color: #222;
        padding: 7px 10px 7px 10px;
        width: 100%;
        height: 100%;
    }
    .collabSortDiv > div + div > a > span {
        /*float: left;*/
        clear: left;
        //margin-left: 2px;
        margin-right: 7px;
        margin-bottom: 5px;
        margin-top: 3px;
        height: 9px;
        width: 9px;
    }/*
    .collabSortDiv > div.current > a > span {
        background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabSprites.png')}) no-repeat 0px -1891px;
    }*/
    .collabSortDiv > div > a:focus,
    .collabSortDiv > div > a:active,
    .collabSortDiv > div > a:hover {
        background-color: #F4F4F4;
        color: #015BA7;
        outline: medium none;
        text-decoration: none;
        transition: background-color 0.15s ease-in-out 0.1s;
    }
    .collabFeedWrapper{
        padding-top: 20px;
        //width: 100%;
        clear: both;
        width:540px;
        margin-top: 10px;
    }
    .collabFeedWrapper > div.feedItem{
        min-height: 47px;
        white-space: normal;
        word-wrap: break-word;
        margin: 0px 0px 0px 0px;
        padding: 0px 5px 15px 5px;   
        position: relative;
        /*float: left;*/
        /* width: 500px;
        width: 700px;*/
        margin-left: auto;
        margin-right: auto;
        display: block;
        overflow: visible;
    }
    .collabFeedWrapper > .feedItem .collabFeedItemMenu > div > a {
        display: none;
    }
    .collabFeedWrapper > .feedItem .collabFeedItemMenu > div > a.active {
        display: block;
    }
    .collabFeedWrapper > .feedItem .collabFeedItemMenu {
        background-color: #f8f8f8;
        border: 1px solid #e2e2e2;
        position: absolute;
        top: 10px;
        width: 17px;
        border-radius: 3px !important;
        height: 17px;
    }
    .collabFeedWrapper > .feedItem .collabFeedItemMenu > a {
        display: block;
        width: 13px;
        margin-top: 2px;
        height: 11px;
        margin-left: 1px;
        padding-top: 3px;
        text-indent: -99999px;
        line-height: 1px;
    }
    .collabFeedWrapper > .feedItem .collabFeedItemMenu > a > span {
        display: block;
        height: 4px;
        width: 8px;
        margin-left: 4px;
        /*background: #f8f8f8 url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabSprites.png')}) no-repeat 0px -1634px;*/
    }
    .collabFeedWrapper > .feedItem .collabFeedItemMenu:hover,
    .collabFeedWrapper > .feedItem .collabFeedItemMenu:focus,
    .collabFeedWrapper > .feedItem .collabFeedItemMenu:active {
        cursor: pointer;
        border: 1px solid #bfbfbf;
        background-color: -webkit-linear-gradient(#f8f8f8, #eeeeee);
        box-shadow: inset 0 1px 0 rgba(255, 255, 255, .1), 0px 1px 0 rgba(0, 0, 0, .1);
    }/*
    .collabFeedWrapper > .feedItem .collabFeedItemMenu:hover > a > span,
    .collabFeedWrapper > .feedItem .collabFeedItemMenu:focus > a > span,
    .collabFeedWrapper > .feedItem .collabFeedItemMenu:active > a > span {
        background: #f8f8f8 url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabSprites.png')}) no-repeat 0px -1648px;
    }*/
    .collabFeedWrapper > .feedItem .bookmarkIcon {
        display: none;
        width: 16px;
        height: 16px;
        text-indent: -99999px;
        font-size: 1px;
        overflow: hidden;
        position: absolute;
        top:0px;
        right:0px;
        /*background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabSprites.png')}) no-repeat 0 -702px;*/
    }
    .collabFeedWrapper > .feedItem .bookmarkIcon.active {
        display: block;
    }

    .collabFeedWrapper > .feedItem .collabFeedItemMenu > div > span > a {
        width: 100%;
    }

    .collabFeedWrapper > .feedItem .collabFeedItemMenu > a:active,
    .collabFeedWrapper > .feedItem .collabFeedItemMenu > a:focus,
    .collabFeedWrapper > .feedItem .collabFeedItemMenu > a:hover {
/*      cursor: pointer; */
/*      border: 1px solid #bfbfbf; */
/*      background-color: -webkit-linear-gradient(#f8f8f8, #eeeeee); */
/*      box-shadow: inset 0 1px 0 rgba(255, 255, 255, .1), 0px 1px 0 rgba(0, 0, 0, .1); */
/*      background: #f8f8f8 url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabSprites.png')}) no-repeat 4px -1629px; */
    }
    .collabFeedWrapper > .feedItem .collabFeedItemMenu > div {
        display: none;
        padding: 10px 0px 10px 0px;
        position: absolute;
        top: 19px;
    /*left: -16px;*/
    	right: 0px;
        border: 1px solid #e2e2e2;
        border-radius: 3px !important;
        box-shadow: 0 2px 4px rgba(0,0,0,.2);
        background-color: #FFF;
        z-index: 2;
    }
    .collabFeedWrapper > .feedItem .collabFeedItemMenu > div a {
        /*float: left;*/
        clear: both;
        color: #222;
        padding: 7px 20px 7px 20px;
        margin: 0;
        line-height: 13px;
        white-space: nowrap;
    }
    .collabFeedWrapper > .feedItem .collabFeedItemMenu > div a:hover,
    .collabFeedWrapper > .feedItem .collabFeedItemMenu > div a:focus,
    .collabFeedWrapper > .feedItem .collabFeedItemMenu > div a:active {
        background-color: #ececec;
        text-decoration: none;
        text-color: #222;
    }
    .collabFeedWrapper > .feedItem .collabFeedItemMenu > div.active {
        display: block;
    }
    .collabFeedWrapper > .feedItem .collabTopics {
        margin-top: 8px;
        margin-bottom: 13px;
    }
    .collabFeedWrapper > .feedItem .collabTopics > a:first-child {
        color: #015ba7;
    }
    .collabFeedWrapper > .feedItem .collabTopics > a {
        color: #888;
        font-size: .9em;
    }
    .collabFeedWrapper > .feedItem .collabTopics a:hover,
    .collabFeedWrapper > .feedItem .collabTopics a:focus,
    .collabFeedWrapper > .feedItem .collabTopics a:active {
        color: #015ba7;
    }
    .collabFeedWrapper > div.feedItem > div:first-child {
        /*float: left;*/
        clear: left;
        width: 45px;
        padding-left: 0px;
    }
    .feedItem > div:first-child > a > img,
    .feedItem > div:first-child > img {
        height: 45px;
        width: 45px;
    }
    .collabFeedWrapper > div.feedItem > div + div{
        // margin-left: 13px;
        // width: 100%;
        // max-width: 461px;
        display: block;  
        white-space: normal;
        word-wrap: break-word;
        position: relative;
        display: inline-block;
    }
    .collabFeedWrapper > div.feedItem > div.createCollabComment {
        width: 100%;
    	padding-right: 65px;
    }
    .collabFeedWrapper > div.feedItem > div.collabComment {
        margin-bottom: -3px;
        display: block;
    }
    .collabFeedWrapper > div.feedItem > div.collabComment > .collabComments {
        display: inline-block;
        width: 100%;
        padding-right: 50px;
    }
    .collabFeedWrapper > div.feedItem > div + div > div:first-child,
    #CollabShareModal div.feedItem > div + div > div:first-child{
        padding-bottom: 8px;
        line-height: 1em;
    }
    .collabFeedWrapper > div.feedItem > div + div > div:first-child > span:first-child > a:first-child{
        font-weight: 600;
    }
    .collabFeedWrapper > div.feeditem > div + div > div + div + div{
        margin-top: 12px;
        margin-bottom: 10px;
    }
    
    .collabFeedWrapper .fileBlock,
    .collabFeedWrapper .linkBlock,
    #CollabShareModal .fileBlock,
    #CollabShareModal .linkBlock{
        border: 1px solid #EDEDED;
        border-radius: 2px;
        margin-top: 10px;
        margin-bottom: 10px;
        padding: 12px 10px 11px;
        display: block;
        overflow: visible;
        /*float: left;*/
        width: 100%;
    }
    #CollabShareModal .linkBlock a,
    #CollabShareModal .fileBlock a {
        cursor: default;
    }
    .collabComment .fileBlock {
        overflow: visible;
    }
    .collabFeedWrapper .collabComment .fileBlock {
        border: none;
        margin-top: 0px;
        margin-bottom: 0px;
        padding: 0px;
        position: relative;
    }
    .feedItem .fileBlock .collabDefaultPreview {
        height: 32px;
        width: 32px;
        /*background-image: url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabExtensionImages.png')});*/
    }
    .collabFeedWrapper .fileBlock > div > a:first-child,
    #CollabShareModal .fileBlock > div > a:first-child {
        padding-bottom: 6px;
        width: 100%;
        clear: both;
    }
    .collabFeedWrapper .fileBlock > div > a,
    .collabFeedWrapper .fileBlock > div > span,
    #CollabShareModal .fileBlock > div > a,
    #CollabShareModal .fileBlock > div > span,
    .collabFeedWrapper .feedItem .moreCommentActions {
        vertical-align: top;
        /*float: left;*/
    }
    .collabFeedWrapper .fileBlock > div > a > span,
    #CollabShareModal .fileBlock > div > a > span {
        color: #716562;
        font-size: .9em;
    }
    .collabFeedWrapper .fileBlock > div > a + a,
    #CollabShareModal .fileBlock > div > a + a {
        font-size: .9em;
        padding-left: 18px;
        /*background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabFiles.png')}) no-repeat 0px -22px;*/
    }
    .collabFeedWrapper .fileBlock .moreActionsAnchor {
        vertical-align: top;
        font-size: .9em;
        padding-right: 12px;
        /*background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabSprites.png')}) no-repeat 68px -1836px;*/
    }
    .collabFeedWrapper .feedItem .moreCommentActions {
        height: 12px;
        font-size: .9em;
        padding-right: 12px;
        /*background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabSprites.png')}) no-repeat 66px -1836px;*/
    }
    #CollabShareModal .fileBlock .moreActionsAnchor {
        vertical-align: top;
        font-size: .9em;
        padding-right: 12px;
        /*background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabSprites.png')}) no-repeat 76px -1836px;*/
    }
	/*
    .collabFeedWrapper .fileBlock .moreActionsAnchor:hover,
    .collabFeedWrapper .fileBlock .moreActionsAnchor:focus,
    .collabFeedWrapper .fileBlock .moreActionsAnchor:active {
        background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabSprites.png')}) no-repeat 68px -1827px;
    }
    .collabFeedWrapper .feedItem .moreCommentActions:hover,
    .collabFeedWrapper .feedItem .moreCommentActions:focus,
    .collabFeedWrapper .feedItem .moreCommentActions:active {
        background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabSprites.png')}) no-repeat 68px -1827px;
    }*/
    .collabFeedWrapper .fileBlock .removedFile {
        /*float: left;*/
        height: 32px;
        width: 32px;
        /*background-image: url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabExtensionImages.png')});*/
    }
    .collabFeedWrapper .fileBlock .removedFile + div {
        /*float: left;*/
        padding-top: 8px;
        padding-left: 5px;
    }
    .collabFeedWrapper .fileBlock > div,
    #CollabShareModal .fileBlock > div {
        padding-left: 9px;
        max-width: 300px;
    }
    .collabFeedWrapper .linkBlock > span,
    #CollabShareModal .linkBlock > span {
        color: #7D7D84;
    }
    .collabFeedWrapper .fileBlock > div,
    .collabFeedWrapper .fileBlock > span > a > img,
    #CollabShareModal .fileBlock > div,
    #CollabShareModal .fileBlock > span > a > img{
        /*float: left;*/
    }
    .collabFeedWrapper .fileBlock > span > a > img,
    #CollabShareModal .fileBlock > span > a > img {
        border: 1px solid #d0d0d0;
    }
    .collabFeedWrapper .collabComment .fileBlock > span > a > img {
        max-width: 60px;
        max-height: 60px;
        margin: 4px 3px 3px 0;
    }
    .fileBlock > span > a:hover > img,
    .fileBlock > span > a:active > img,
    .fileBlock > span > a:focus > img {
        outline: 1px auto;
    }
    .collabFeedWrapper .collabComment .fileBlock > span + div > a + a + span + a {
        margin-top: 2px;
        line-height: 12px;
    }
    .collabFeedWrapper .feedItem .moreActionsContainer {
        position: relative;
        display: inline;
        /*float: left;*/
    }
    .collabFeedWrapper .feedItem .moreActions {
        display: none;
        border-radius: 5px !important;
        box-shadow: 0 2px 5px #a0acab;
        background-color: #fff;
        padding-top: 5px;
        padding-bottom: 5px;
        padding-left: 13px;
        padding-right: 8px;
        position: absolute;
        z-index: 5;
        border: 1px solid #b6b6b6;
        left: -13px;
        width: 140px;
    }
    .collabFeedWrapper .feedItem .moreActionsAnchor + .moreActions {
        top: -15px;
    }
    .collabFeedWrapper .feedItem .moreCommentActions + .moreActions {
        top: -16px;
    }
    .collabFeedWrapper .feedItem .moreActions.active {
        display: block;
    }
    .collabFeedWrapper .feedItem .moreActions > div:first-child > a {
        color: rgb(66, 139, 202);
        display: inline;
        font-size: .9em;
        padding-right: 12px;
        /*background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabSprites.png')}) no-repeat 68px -1836px;*/
    }
    .collabFeedWrapper .feedItem .moreActions > div:first-child > a:hover,
    .collabFeedWrapper .feedItem .moreActions > div:first-child > a:focus,
    .collabFeedWrapper .feedItem .moreActions > div:first-child > a:active {
        color: rgb(66, 139, 202);
        text-decoration: none;
        /*background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabSprites.png')}) no-repeat 68px -1827px;*/
    }
    .collabFeedWrapper .feedItem .moreActions > div:first-child + div {
        border-bottom: 1px solid rgb(212, 218, 220);
    }
    .collabFeedWrapper .feedItem .moreActions > div.follow > a {
        padding-left: 18px;
        /*background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabFollowSprite.png')}) no-repeat 0px 0px;*/
    }
    .collabFeedWrapper .feedItem .moreActions > div.follow.following > a {
        /*background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabFollowSprite.png')}) no-repeat 0px -27px;*/
    }
    .collabFeedWrapper .feedItem .moreActions > div {
        padding-top: 7px;
        padding-bottom: 7px;
        margin-top: 1px;
        margin-bottom: 1px;
        margin-left: -9px;
        padding-left: 8px;
        display: none;
    }
    .collabFeedWrapper .feedItem .moreActions > div.active {
        display: block;
    }
    .collabFeedWrapper .feedItem .moreActions > div > a {
        color: #222;
        height: 16px;
        display: block;
    }
    .collabFeedWrapper .feedItem .moreActions > div > a:active,
    .collabFeedWrapper .feedItem .moreActions > div > a:focus,
    .collabFeedWrapper .feedItem .moreActions > div > a:hover {
        color: #015ba7;
        text-decoration: none;
    }
    
    .collabFeedWrapper > div > div + div > div + div,
    #CollabShareModal > div > div + div > div + div{
        clear:both;
        /*float: left;*/
        width:100%;
    }
    .collabFeedWrapper > div > div + div > div + div > ul,
    #CollabShareModal > div > div + div > div + div > ul{
        /*float: left;*/
        clear: both;
        width:100%;
        padding: 0px 0px 0px 0px;
        margin: 10px 0px 0px 0px;
        height: .9em;
    }
    .collabFeedWrapper .collabComment > span > div > div + div > ul {
        /*float: left;*/
        clear: both;
        width:100%;
        padding: 0px 0px 0px 0px;
        margin: 8px 0 0 0;
    }
    .collabFeedWrapper > div > div + div > div + div > ul li,
    .collabFeedWrapper .collabComment > span > div > div + div > ul li{
        /*float: left;*/
        font-size: .9em;
        line-height: 13px;
    }
    .collabFeedWrapper > div > div + div > div + div > ul li > span,
    .collabFeedWrapper .collabComment > span > div > div + div > ul li span {
        /*float: left;*/
    }
    .collabFeedWrapper > div > div + div > div + div > ul li > a,
    .collabFeedWrapper > div > div + div > div + div > ul li > span > a,
    .collabFeedWrapper > div > div + div > div + div > ul li > span > span,
    .collabFeedWrapper .collabComment > span > div > div + div > ul li a{
        /*float: left;*/
        font-size: .9em;
    }
    .collabFeedWrapper > div > div + div > div + div >  ul li.timeStamp a,
    .collabFeedWrapper > div > div + div > div + div >  ul li.timeStamp span,
    .collabFeedWrapper .collabComment > span > div > div + div > ul li,
    .collabFeedWrapper .collabComment > span > div > div + div > ul li a {
        color: #716562;
    }
    .collabFeedWrapper .collabComment > span > div > div + div > ul li a:active,
    .collabFeedWrapper .collabComment > span > div > div + div > ul li a:hover,
    .collabFeedWrapper .collabComment > span > div > div + div > ul li a:focus {
        color: #015BA7;
        text-decoration: none;
    }
    .collabFeedWrapper > div > div + div > div + div > ul li.timeStamp a:active,
    .collabFeedWrapper > div > div + div > div + div > ul li.timeStamp a:hover,
    .collabFeedWrapper > div > div + div > div + div > ul li.timeStamp a:focus {
        color: #015BA7;
    }
    .collabFeedWrapper,
    .collabFeedWrapper .collabComment{
        /*float: left;*/ 
        clear: both;
        width: 100%;
    }
    .collabFeedWrapper .collabComment > span:first-child > div:first-child {
        border-top: 1px solid #F3F3F3;
    }
    .collabFeedWrapper .collabComment > div.createCollabComment:first-child {
        border-top: 1px solid #F3F3F3;
    }
    .collabFeedWrapper .createCollabComment {
        //margin-left: 58px;
        position: relative;
    }
    .collabFeedWrapper .createCollabComment .newCommentFileDiv > form > input {
        /*float: left;*/
        height: 20px;
    }
    .collabFeedWrapper .createCollabComment .newCommentFileDiv > form > a {
        /*float: left;*/
        clear: left;
    }
    .collabFeedWrapper .createCollabComment .newCommentFileDiv {
        display: none;
    }
    .collabFeedWrapper .createCollabComment .newCommentFileDiv.active {
        display: block;
    }
    .collabFeedWrapper .createCollabComment .existingCommentFileDiv {
        display: none;
    }
    .collabFeedWrapper .createCollabComment .existingCommentFileDiv.active {
        display: block;
    }
    .collabFeedWrapper .createCollabComment .CollabattachFileToComment {
        display: none;
    }
    .collabFeedWrapper .createCollabComment .collabAttachFileToComment.active {
        display: inline-block;
    }
    .collabFeedWrapper .collabComment > span > div,
    .collabFeedWrapper .createCollabComment {
        position: relative;
        /*float: left;*/
        clear: both;
        width: 100%;
        min-height: 34px;
        /*padding-right: 18px;*/
        padding-bottom: 4px;
        margin-top: 10px;
        /*background: none repeat scroll 0% 0% #FBFBFB;*/
        /*border-bottom: 1px solid #F3F3F3;*/
        white-space: normal;
        word-wrap: break-word;
        line-height: 16px;
    }
    .collabFeedWrapper .collabComment > span > div.newCollabCommentPlaceholder {
        margin-top: 0px;
    	padding-left: 40px;
    }
    .collabFeedWrapper .createCollabComment,
    .collabFeedWrapper .collabComment .newCollabCommentPlaceholder {
        display: none !important;
        border-bottom-left-radius: 10px;
        border-bottom-right-radius: 10px;
    }
    .collabFeedWrapper .createCollabComment.active,
    .collabFeedWrapper .collabComment .newCollabCommentPlaceholder.active {
        display: block !important;
    }
    .collabFeedWrapper .collabLike,
    .collabFeedWrapper .showMore {
        display: none;
        /*float: left;*/
        clear: both;
        width: 100%;
        padding: 6px 10px;
        background: none repeat scroll 0% 0% #FBFBFB;
        border-bottom: 1px solid #F3F3F3;
        color: #7B667B;
        font-size: 0.9em;
        line-height: 16px;
		border-radius: 10px;
		margin-top: 2px;
    }
    .collabFeedWrapper .collabLike.active,
    .collabFeedWrapper .showMore.active {
        display: block;
    }
    .collabFeedWrapper .collabComment > span > div > div:first-child {
        /*float: left;*/
        clear: left;
    }
    .collabFeedWrapper .collabComment > span > div > div > a > img,
    .collabFeedWrapper .collabComment > span > div > div > img {
        width: 30px;
        height: 30px;
    }
    .collabFeedWrapper .collabComment > span > div > div + div {
        /*float: left;*/
        padding-left: 10px;
    }
    .collabFeedWrapper .collabComment > span > div > div + div > div:first-child {
        padding-bottom: 8px;
    }
    .collabFeedWrapper .collabComment > span > div > div + div > div + div {
        clear:both;
        /*float: left;*/
        width: 100%;
    }
    .collabFeedWrapper .collabComment > span > div #DeleteCollabComment {
        text-indent: -99999px;
        font-size: 1px;
        width: 9px;
        height: 8px;
        position: absolute;
        top: 5px;
        right: 999999px;
        /*background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabCommentXSprite.png')}) no-repeat 0px 0px;*/
    }
    .collabFeedWrapper .collabComment > span > .firstColor:hover #DeleteCollabComment,
    .collabFeedWrapper .collabComment > span > .firstColor:focus #DeleteCollabComment,
    .collabFeedWrapper .collabComment > span > .firstColor:active #DeleteCollabComment {
        right: 6px; 
    }
    .collabFeedWrapper .collabComment > span > .firstColor #DeleteCollabComment:hover,
    .collabFeedWrapper .collabComment > span > .firstColor #DeleteCollabComment:focus,
    .collabFeedWrapper .collabComment > span > .firstColor #DeleteCollabComment:active {
        right: 6px;
        /*background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabCommentXSprite.png')}) no-repeat 0px -8px;*/
    }
    .collabFeedWrapper .collabComment > span > .secondColor:hover #DeleteCollabComment,
    .collabFeedWrapper .collabComment > span > .secondColor:focus #DeleteCollabComment,
    .collabFeedWrapper .collabComment > span > .secondColor:active #DeleteCollabComment {
        right: 45px; 
    }
    .collabFeedWrapper .collabComment > span > .secondColor #DeleteCollabComment:hover,
    .collabFeedWrapper .collabComment > span > .secondColor #DeleteCollabComment:focus,
    .collabFeedWrapper .collabComment > span > .secondColor #DeleteCollabComment:active {
        right: 45px;
        /*background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabCommentXSprite.png')}) no-repeat 0px -8px;*/
    }
    .collabFeedWrapper .collabComment .collabTotalLikes {
        width: 16px;
        height: 16px;
        padding: 4px 8px;
        margin-right: 6px;
        margin-top: -3px;
        /*background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabSprites.png')}) no-repeat 0px -522px;*/
    }
    .collabFeedWrapper .collabComment .loadingComment {
        width: 100%;
        height: 80px;
        display: none;
        /*background: #FFF url({!urlfor($Resource.GovGrantsExternal, 'Feedback/css/ajax-loader.gif')}) no-repeat 50% 24px;*/
    }
    .collabFeedWrapper .collabComment .loadingComment.active {
        display: block;
    }
    .collabFeedWrapper .collabComment .newCollabCommentPlaceholder {
        width:100%;
    }
    .collabFeedWrapper .collabComment .newCollabCommentPlaceholder > textarea {
        width: 100%;
        resize: none;
        overflow: hidden;
        background-color: #FFF;
        border: 1px solid #EDEDED;
        padding: 4px;
        line-height: 16px;
        word-wrap: break-word;
        border-radius: 3px !important;
        color: #888;
    }
    .collabFeedWrapper .createCollabComment > div:first-child,
    .collabFeedWrapper .createCollabComment > div:first-child > a {
        position: absolute;
    }
    .collabFeedWrapper .createCollabComment > div:first-child > a > img {
        width: 30px;
        height: 30px;
    }
    .collabFeedWrapper .createCollabComment > div:first-child + div {
        /*float: left;*/
    /*padding-left: 40px;*/
        clear: none;
        overflow: auto;
        width: 100%;
    }
    .collabFeedWrapper .createCollabComment > div > textarea {
        /*float: left;*/
        overflow: hidden;
        resize: none;
        background-color: #FFF;
        border: 1px solid #EDEDED;
        padding: 4px;
        line-height: 16px;
        word-wrap: break-word;
        border-radius: 3px !important;
        width: 100%;
        margin-bottom: 5px;
    }
    .collabFeedWrapper .createCollabComment > div + div > a.active {
        display: inline-block;
    }
    .collabFeedWrapper .createCollabComment > div + div > a {
        display: none;
        /*float: left;*/
        clear: left;
        padding-left: 21px;
        font-weight: bold;
        /*background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabSprites.png')}) no-repeat 0 -1022px;*/
    }
    .collabFeedWrapper .createCollabComment > div + div > input{
        width: 82px;
        font-size: 1em !important;
        float: right;
        clear: right;
    }
    .collabFeedWrapper .collabCommentUploadDiv {
        background-color: #fff;
        padding-top: 5px;
        padding-bottom: 5px;
        padding-left: 5px;
        padding-right: 5px;
        border: 1px solid #b6b6b6;
        z-index: 5;
        width: auto;
        display: none;
        position: absolute;
        bottom: -53px;
        box-shadow: rgb(160, 172, 171) 0px 2px 5px 0px;
        border-radius: 5px !important;
    }
    .collabFeedWrapper .collabCommentUploadDiv.active {
        display: block;
    }
    .collabFeedWrapper .collabCommentUploadDiv > a {
        margin-top: 1px;
        margin-bottom: 1px;
        padding-left: 5px;
        padding-right: 5px;
        font-size: 1em;
        line-height: 23px;
        font-weight: normal;
        text-decoration: none;
        color: #015ba7;
        display: block;
    }
    #CollabShareModal .feedItem {
        /*float: left;*/
        clear: both;
        width: 100%;
    }
    #CollabShareModal .feedItem > div:first-child {
        /*float: left;*/
        clear: left;
        width: 45px;
    }
    #CollabShareModal .feedItem > div:first-child + div {
        padding-left: 13px;
        /*float: left;*/
        white-space: normal;
        word-wrap: break-word;
        width: 420px;
    }
    div.ui-dialog-titlebar {
        display: none;
    }
    
    div.ui-dialog-content {
        padding: 0px !important;
    }
    
    div.ui-dialog.ui-widget-content {
        padding: 0px;
        border-radius: 6px 6px 0px 0px !important;
        border: none;
    }
    
    div.ui-widget-content a {
        color: #428BCA;
    }
    
    div.sidebarWidget {
        padding: 15px 15px 25px 15px;
        height: auto;
    }
    #CollabPreviewModal {
        position: relative;
        height: 511px !important;
    }
    #CollabPreviewModal > div {
        position: relative;
        height: 480px;
        width: 640px;
        padding: 0px;
    }
    #CollabPreviewModal > span,
    #CollabPreviewModal > span > p {
        position: relative;
        width: 641px !important;
    }
    .collabModal > a {
        text-indent: -99999px;
        line-height: 1px;
        position: absolute;
        right: 10px;
        top: 5px;
        height: 20px;
        width: 20px;
        z-index: 1;
        /*background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabXButtons.png')}) no-repeat 0px 0px;*/
    }
    #CollabUploadCommentFile.collabModal a.actionClose,
    #CollabUploadFiles.collabModal a.actionClose {
        position: absolute;
        right: 5px;
        top: 0px;
    }
    #CollabShareModal div.share + a {
        text-indent: -99999px;
        position: absolute;
        right: 10px;
        top: 5px;
        height: 20px;
        width: 20px;
        z-index: 1;
        /*background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabXButtons.png')}) no-repeat 0px 0px;*/
    }
    #CollabUploadFiles table.dataTable .actionAttach {
        text-decoration: none;
    }
    #CollabUploadFiles .collabTableBackground .panel.panel-default {
        padding-bottom: 8px;
    }
    #CollabUploadFiles .collabTableBackground .panel.panel-default .panel-heading {
        margin-bottom: 15px;
    }
    
    .collabPanel .panel-heading,
    .collabPanel .panel-heading-title,
    .collabModal .panel-heading,
    .collabModal .panel-heading-title{
        padding-top:0px !important;
        padding-bottom:0px !important; 
        display:block; 
        /*float: left;*/
        width:100%;
           
    }
    
    .collabColleagues >  .panel-heading {
        padding-top: 0px !important;
        padding-bottom: 0px !important;
        display: block !important;
        /*float: left !important;*/
        width: 100%;
        border-radius: 0px 0px 0 0 !important;
        background-color: #005fb2 !important;
        color: white !important;
    }
    
    
    .panel-heading-title h2{
        display:block;
        /*float: left;*/
    }
    #CollabUploadCommentFile .list.dataTable,
    #CollabUploadFiles .list.dataTable {
        width: 100% !important;
    }
    #DisplayCollabLikes > ul.collabLikesList {
        width: 390px;
        margin: 0px 5px 30px 5px;
        padding: 0px;
        list-style-type: none;
        /*float: left;*/
        position: relative;
    }
    #DisplayCollabLikes > div {
        padding-bottom: 5px;
        padding-top: 5px;
        margin-left: 5px;
        margin-right: 5px;
        clear: both;
        border-bottom: 1px solid gray;
    }
    #DisplayCollabLikes > ul.collabLikesList > li {
        width: 380px;
        height: 44px;
        /*float: left;*/
        padding-bottom: 5px;
        padding-top: 5px;
        margin-left: 5px;
        margin-right: 5px;
        clear: both;
        border-bottom: 1px solid gray;
    }
    #DisplayCollabLikes > ul.collabLikesList > li > a {
        white-space: nowrap;
        text-overflow: ellipsis;
        overflow: hidden;
        width: 100%;
        /*float: left;*/
    }
    #DisplayCollabLikes > ul.collabLikesList > li > div:first-child {
        /*float: left;*/
        clear: left;
    }
    #DisplayCollabLikes > ul.collabLikesList > li > div:first-child > a.collabImage {
        /*float: left;*/
        display: block;
        width: 34px;
    }
    #DisplayCollabLikes > ul.collabLikesList > li > div:first-child > a + a {
        /*float: left;*/
        display: block;
        overflow: hidden;
        text-overflow: ellipsis;
        width: 220px;
        margin-right: 20px;
    }
    #DisplayCollabLikes > ul.collabLikesList > li > div:first-child + div {
        /*float: left;*/
    }
    #DisplayCollabLikes > ul.collabLikesList > li > div:first-child + div > a { 
        padding: 8px 0px 0px 20px;
        /*float: left;*/
        display: inline;
        /*background: url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabFollowSprite.png')}) no-repeat 0px 7px;*/
    }
    #DisplayCollabLikes > ul.collabLikesList > li > div:first-child + div > a:hover,
    #DisplayCollabLikes > ul.collabLikesList > li > div:first-child + div > a:focus,
    #DisplayCollabLikes > ul.collabLikesList > li > div:first-child + div > a:active {
        text-decoration: none;   
    }
    #DisplayCollabLikes > ul.collabLikesList > li > div:first-child + div > a.following { 
        background-position: 0px -19px;
    }
    #DisplayCollabLikes > ul.collabLikesList > li > div:first-child + div > a > span { 
        display: inline;
        width: 16px;
        height: 16px;
        /*float: right;*/
        margin-left: 5px;
        /*background: url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabFollowSprite.png')}) no-repeat 0px -54px;*/
    }
    #DisplayCollabLikes > ul.collabLikesList > li > div:first-child + div > a > span:hover,
    #DisplayCollabLikes > ul.collabLikesList > li > div:first-child + div > a > span:focus,
    #DisplayCollabLikes > ul.collabLikesList > li > div:first-child + div > a > span:active { 
        background-position: 0px -75px;
    }
    #DisplayCollabLikes > ul.collabLikesList img {
        margin: 2px;
        height: 30px;
        width: 30px;
        /*float: left;*/
    }
    #DisplayCollabLikes > ul.collabLikesList > li.nextLikePage {
        width: 35px;
        position: absolute;
        right: 6px;
        bottom: -27px;
        border: none;
        height: auto;
    }
    #DisplayCollabLikes > ul.collabLikesList > li.prevLikePage {
        width: 35px;
        position: absolute;
        left: 6px;
        bottom: -27px;
        border: none;
        height: auto;
    }
    #DisplayCollabLikes > ul.collabLikesList > li.nextLikePage > a {
        width: 28px;
    }
    #DisplayCollabLikes > ul.collabLikesList > li.prevLikePage > a {
        width: 28px;
    }
    #CollabUploadNewVersion > div {
        height: 18px;
        padding: 5px;
    }
    #CollabUploadNewVersion > div > div:first-child + div > span {
        padding-top: 20px;
        display: block;
        /*float: left;*/
    }
    #CollabUploadNewVersion > div > div:first-child + div > textarea {
        resize: none;
        display: block;
        /*float: left;*/
        height: 54px;
        width: 100%;
    }
    #CollabUploadNewVersion > div > input {
        margin: 5px;    
    }
        #CollabSharingModal > div {
            padding: 15px;
            padding-top: 30px;
            /*float: left;*/
            width: 100%;
        }
        #CollabSharingModal > div > div:first-child + div {
            /*float: left;*/
            width: 100%;
        }
        #CollabSharingModal .shareWith,
        #CollabSharingModal .fileSharingHeader,
        #CollabSharingModal .fileSharingList {
            margin: 0;
            padding: 0;
            list-style-type: none;
        }
        #CollabSharingModal .fileSharingList {
            /*float: left;*/
            width: 616px;
            height: 200px;
            overflow-y: scroll;
        }
        #CollabSharingModal .shareWith {
            padding-bottom: 5px;
            padding-left: 20px;
            /*background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabFiles.png')}) no-repeat 0px -56px;*/
        }
        #CollabSharingModal .shareWith + a {
            position: absolute;
            right: 60px;
            top: 62px;
            font-weight: bold;
        }
        #CollabSharingModal .sharingDiv,
        #CollabSharingModal .makeFilePrivate {
            display: none;
        }
        #CollabSharingModal .sharingDiv.active,
        #CollabSharingModal .makeFilePrivate.active {
            display: block;
        }
        #CollabSharingModal .fileSharingHeader {
            /*float: left;*/
            border-bottom: 0px;
            width: 100%;
        }
        #CollabSharingModal .shareWith > li,
        #CollabSharingModal .fileSharingHeader > li,
        #CollabSharingModal .fileSharingList > li > div {
            display: inline;
            list-style: none;
        }
        #CollabSharingModal .fileSharingList > li:empty {
            display: none;
        }
        #CollabSharingModal .fileSharingList > li > div:first-child + div > a {
            font-weight: bold;
        }
        #CollabSharingModal .fileSharingList > li > div:first-child + div + div > a > span {
            width: 16px;
            height: 8px;
            margin-top: 2px;
            /*float: right;*/
            /*background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabFiles.png')}) no-repeat 0px -186px;*/
        }
        #CollabSharingModal .fileSharingList .sharingSettings {
            display: none;
            border: 1px solid #d4dadc;
            position: absolute;
            /*float: left;*/
            right: 28px;
            top: 102px;
            background-color: white;
            box-shadow: 0 2px 5px #acacac;
            padding-top: 9px;
            padding-bottom: 9px;
            padding-right: 4px;
            padding-left: 4px;
            padding: 5px;
            border-radius: 5px !important;
        }
        #CollabSharingModal .fileSharingList .sharingSettings.active {
            display: block;
        }
        #CollabSharingModal .fileSharingList .sharingSettings > div {
            display: block;
            width: 104px;
            border-radius: 7px !important;
            clear: both;
            padding: 4px 10px;
        }
        #CollabSharingModal .fileSharingHeader + div {
            border: solid 1px gray;
            /*float: left;*/
            border-top: 0px;
            width: 100%;
        }
        #CollabSharingModal .fileSharingHeader > li:first-child {
            width: 80%;
            border-right: 0px;
            padding-left: 5px;
        }
        #CollabSharingModal .fileSharingHeader > li:first-child + li {
            width: 20%;
            padding-left: 5px;
        }
        #CollabSharingModal .fileSharingHeader > li {
            /*float: left;*/
            border-bottom: 0px;
            border: solid 1px gray;
            list-style: none;
        }
        #CollabSharingModal .fileSharingList > li:first-child {
            border: 0px;
        }
        #CollabSharingModal .fileSharingList > li {
            border-top: solid 1px gray;
            display: block;
            padding: 3px;
            height: 37px;
            width: 100%;
            clear: both;
            list-style: none;
        }
        #CollabSharingModal .fileSharingList > li > div:first-child {
            margin-right: 5px;
        }
        #CollabSharingModal .fileSharingList > li > div:first-child + div {
            padding-top: 7px;
            width: 70%;
        }
        #CollabSharingModal .fileSharingList > li > div:first-child + div + div {
            padding-left: 40px;
            padding-top: 7px;
            width: 24%;
        }
        #CollabSharingModal .fileSharingList > li > div.orgPhoto:first-child,
        #CollabSharingModal .fileSharingList > li > div:first-child > a > img {
            height: 30px;
            width: 30px;
        }
        #CollabSharingModal .fileSharingList > li > div.orgPhoto {
            padding-right: 15px;
            padding-left: 15px;
            padding-top: 5px;
            padding-bottom: 10px;
            /*background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabCompanyShare.png')}) no-repeat 0px 0px;*/
        }
        #CollabSharingModal .fileSharingList > li .shareAnchor + a {
            display: block;
            height: 16px;
            width: 16px;
            /*float: right;*/
            /*background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabFollowSprite.png')}) no-repeat 0px -54px;*/
        }
        #CollabSharingModal .fileSharingList > li .shareAnchor + a:hover,
        #CollabSharingModal .fileSharingList > li .shareAnchor + a:focus,
        #CollabSharingModal .fileSharingList > li .shareAnchor + a:active {
            /*background: transparent url({!urlfor($Resource.CollabSprites, 'CollabSprites/collabFollowSprite.png')}) no-repeat 0px -75px;*/
        }
        #CollabSharingModal .fileSharingList * {
            /*float: left;*/
        }
        #collabTabsID li { margin-bottom: 0px; }
        #collabTabsID li:hover { border-color: #EEEEEE; } 
        #collabTabsID li a { border: none; border-bottom: 3px solid #FFFFFF; font-size: 14px; }
        #collabTabsID li a:hover { border-bottom: 3px solid #EEEEEE; }
        #collabTabsID collabTabsID li.active a { border-bottom: 3px solid #0272D3; font-weight: bold; }
        #collabTabsID li a span { color: #000000; }
        #collabTabsID li.active a span { color: #428BCA; }
        #myTabs1 { padding-top: 15px; }
        #myTabs1 #myTabbedContent { border-left: 1px solid #DCDCDC; border-right: 1px solid #DCDCDC; border-bottom: 1px solid #DCDCDC; }
        .usrImgLeft,
        .commentImgLeft {
            position: absolute;
            left: 2px;
            top: 0px;
        }
        .usrImgRight,
        .commentImgRight {
            position: absolute;
            right: 2px;
            top: 0px;
        }