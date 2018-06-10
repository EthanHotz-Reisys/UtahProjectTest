public with sharing class SubTotalJSONBuilderCtrl {
    public String selectedFieldsName {get;set;}
    public String selectedoperator {get;  set; }
    private ApexPages.StandardSetController setCon {get; set;}
    public Integer rowNumber {get;set;}   
    public Integer mainRowNumber {get;set;} 
    public String labelValue {get;set;} 
    public String subTotalColumn {get;set;} 
    public String labelColumn {get;set;} 
    public String prefix {get;set;} 
    public String suffix {get;set;} 
    public String expressionTextArea {get;set;} 
    public String finalJSONTextArea {get;set;} 
    public String var {get;set;}    
    public List < WrapperExpressionClass > wrapperExpressionlist {get;set;} 
    public String currentRow {get;set;} 
    private String recordId;
    public String expressionString;
    public String storeResult;
    public String storeTextValue;

    public SubTotalJSONBuilderCtrl(ApexPages.StandardController controller) {
        expressionTextArea = ' ';
        finalJSONTextArea = ' ';
        finalJSONTextArea = '{ ' + ' }';
        recordId = ApexPages.currentPage().getParameters().get('id');
        rowNumber = 0;
        WrapperExpressionClass wrapperExpression = new WrapperExpressionClass(0);
        wrapperExpressionlist = new List < WrapperExpressionClass > ();
        wrapperExpressionlist.add(wrapperExpression);
        var = '(';
    }
    public void addNewRow() {
        expressionTextArea = ' ';
        String newst=' '; 
        String third;  
        String second;    
        try{        
            if(!subTotalColumn.equals(labelColumn)){            
                System.debug('currentRow--->' + currentRow);
                expressionString = ' ';
                Integer currentIndex =  Integer.valueOf(currentRow); 
                System.debug('currentIndex--->' + currentIndex);
                String st= ' {"' + subTotalColumn + '":{"expression":" ';
                third = '","prefix":"' + prefix + '" , "suffix":"' + suffix + '"}';
                for (WrapperExpressionClass wrapperobject: wrapperExpressionlist) {             
                    second =wrapperobject.operator +'parseFloat(recordList[' + wrapperobject.rowNumber + '][\'' + wrapperobject.FieldName + '\'])';
                    newst= newst+second;
                     expressionString =st+newst+third;
                }            
               //  expressionString = wrapperExpressionlist[currentIndex].operator + 'parseFloat(recordList[' + wrapperExpressionlist[currentIndex].rowNumber + '][\'' + wrapperExpressionlist[currentIndex].FieldName + '\'])';
                expressionTextArea = expressionTextArea + expressionString;
                System.debug('expressionTextArea--->' + expressionTextArea);
                rowNumber = rowNumber + 1;
                System.debug('rowNumber---->' + rowNumber);
                System.debug('wrapperExpressionlist---->' + wrapperExpressionlist);
               storeResult = expressionTextArea;
                WrapperExpressionClass wrapperExpressionObject = new WrapperExpressionClass(wrapperExpressionlist.size());
                wrapperExpressionlist.add(wrapperExpressionObject);
                }
            }catch(Exception e){
                ApexPages.AddMessages(e);
        }                
    }

    public void addSubTotalRow() {
        String second;
        string first;
        String third;
        String express = '';
        for (WrapperExpressionClass wrapperobject: wrapperExpressionlist) {
            first = '{"' + mainRowNumber + '":' ;
            second=expressionTextArea;
            //second =  wrapperobject.operator + 'parseFloat(recordList[' + wrapperobject.rowNumber + '][\'' + wrapperobject.FieldName + '\'])';
            third = '","prefix":"' + prefix + '" , "suffix":"' + suffix + '"},"' + labelColumn + '": {"label":"' + labelValue + '"},"isSubTotal":true }}';
            //express = express + second;
            expressionString = first + second + third;
            finalJSONTextArea = expressionString;
        }
        System.debug('expressionString: ' + expressionTextArea);
    }
    
    public PageReference save() {
        System.debug('mainRowNumber------' + mainRowNumber);
        System.debug('subTotalColumn------' + subTotalColumn);
        System.debug('labelColumn----' + labelColumn);
        System.debug('prefix----' + prefix);
        System.debug('suffix--->' + suffix);
        System.debug('labelValue------>' + labelValue);
        return null;
    }
    public void addAnotherString() {
        finalJSONTextArea = ' ';       
        for (WrapperExpressionClass wrapperobject: wrapperExpressionlist) {
            expressionString = wrapperobject.operator + '(recordList[' + wrapperobject.rowNumber + '][\'' + wrapperobject.FieldName + '\'])';
            expressionTextArea = expressionTextArea + expressionString;
        }
        expressionTextArea = storeResult + expressionTextArea;
    }
    
    public void refresh(){
        storeTextValue = expressionTextArea;
        System.debug('storeTextValue------------->'+storeTextValue);
        //expressionTextArea= ' ';
       
        addNewRow(); 
    }
    
    
    public void generateExpression() {      
        expressionTextArea = ''; 
        storeTextValue=storeTextValue+storeResult;
        expressionTextArea = storeTextValue;
    }

    public void changeBracket() {
        expressionTextArea = expressionTextArea + var;
        if (var == '(') {
            var = ')';
        } else {
            var = '(';
        }
    }
    
    // Field Name of Related award
    public List < SelectOption > getFieldNames() {
        List < SelectOption > options = new List < SelectOption > ();
        List < String > fields = new List < String > ();
        GNT__DataTableConfig__c dataTableConfig = [SELECT GNT__FieldNames__c FROM GNT__DataTableConfig__c WHERE Id = : recordId];
        System.debug('dataTableConfig---->' + dataTableConfig);
        fields = dataTableConfig.GNT__FieldNames__c.split(',');
        for (string value: fields) {
            options.add(new SelectOption(value, value));
        }
        return options;
    }

    // To show operator list
    public List < SelectOption > getOperator() {
        List < SelectOption > options = new List < SelectOption > ();
        options.add(new SelectOption('+', '+'));
        options.add(new SelectOption('-', '-'));
        options.add(new SelectOption('*', '*'));
        options.add(new SelectOption('/', '/'));
        options.add(new SelectOption(' ', 'None'));
        return options;
    }

    public Class WrapperExpressionClass {
        public Integer index { get;set;}
        public Integer rowNumber {get;set;}
        public String FieldName {get;set;}
        public String operator { get;set;}

        public WrapperExpressionClass(Integer index) {
            this.index = index;
        }
    }
}