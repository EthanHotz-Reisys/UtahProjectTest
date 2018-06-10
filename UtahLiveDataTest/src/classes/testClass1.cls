public with sharing class testClass1 implements Schedulable {
	public string test {get;set;}
	public List<string> cronIdList {get;set;}
    public testClass1(String s, List<string> cronList) {
        test = s;
		cronIdList = cronList;
    }

	public void execute(SchedulableContext sc){
		System.debug(test);
		DateTime dt = DateTime.now().addMinutes(1);
		string s = '0 ' + dt.minute() + ' ' + dt.hour() + ' ' + dt.day() + ' ' + dt.month() + ' ?';
		
		testClass1 tc = new testClass1('TestString', cronIdList);
		string cronId = System.schedule('Ethan Job'+dt, s ,tc); 
		cronIdList.add(cronId); 
		System.debug(cronIdList);
		//Figure out: how to add cron job ID to list, pass list to new class instance
	}
}