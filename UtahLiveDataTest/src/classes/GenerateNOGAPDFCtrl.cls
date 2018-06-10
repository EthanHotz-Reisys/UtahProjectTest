public class GenerateNOGAPDFCtrl {

    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();

        
        keyValueMap.put('awardId', 'a1U36000000amXwEAI');     

        return JSON.serialize(keyValueMap);
    }
}