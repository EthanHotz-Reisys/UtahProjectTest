/* Controller */
public class SimpleDynamicController {

    public Component.Apex.Detail getDynamicDetail() {
        Component.Apex.Detail detail = new Component.Apex.Detail();
        
        return detail;
    }

    // Just return the first Account, for example purposes only
    public Account acct {
        get { return [SELECT Id, Name, OwnerId FROM Account LIMIT 1]; }
    }
}