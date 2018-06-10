public class SF424DV1Controller{
    public string sign{get; set;}
    public string title{get; set;}
    public string apporg{get; set;}
    public Date subdate{get; set;}
    public String returnString{get; set;}
  
    public void submitForm(){
       // returnString = sign+'-'+title+'-'+apporg+'-'+subdate; 
    returnString = title;
    }


}