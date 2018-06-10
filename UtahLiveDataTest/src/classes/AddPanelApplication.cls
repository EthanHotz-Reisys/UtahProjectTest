global with sharing class AddPanelApplication extends GNT.FlexTableActionHandler  {
	public AddPanelApplication() {}
	global override Map<String,Object> clickHandler(){
		Map<String, Object> resultMap = new Map<String, Object>();   
		try{
	    	
	    }catch(Exception e){
	    	resultMap.put('Message', e.getMessage());
	    }
	    return resultMap;
    }
}