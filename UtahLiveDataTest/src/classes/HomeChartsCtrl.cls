public with sharing class HomeChartsCtrl{
    
    //List<ChartConfig__c> charts;
    public integer row{get;set;}
    
    public HomeChartsCtrl(){
         //charts = new List<ChartConfig__c>();
         //loadChartData();
         row = 3;
    }
  
    /*Alternalte method to display charts dynamically using component */
    
      public Component.Apex.OutputPanel getChartPanel() {
          Component.Apex.OutputPanel dynCharts = new Component.Apex.OutputPanel(layout='inline-block');
          String styleCls ;
         /* if(row == 3){
              styleCls = 'col-lg-4';
          }else{
              styleCls = 'col-lg-6';
          }*/
          styleCls = 'col-md-6';
          /*for(ChartConfig__c chart : charts){
              if(chart.RecordType.Name == 'Pie - Semi Circle Donut'){
                  Component.Apex.OutputPanel chartPanel = new Component.Apex.OutputPanel(styleClass=styleCls );
                  chartPanel.childComponents.add(new Component.ChartSemiCircleDonut(chartName = chart.Name,chartHTMLId = chart.Name.replace(' ','') + 'Id')); 
                  dynCharts.childComponents.add(chartPanel);
              }else if(chart.RecordType.Name == 'Pie - 3D'){
                  Component.Apex.OutputPanel chartPanel = new Component.Apex.OutputPanel(styleClass=styleCls );
                  chartPanel.childComponents.add(new Component.ChartPie3D(chartName = chart.Name,chartHTMLId = chart.Name.replace(' ','') + 'Id')); 
                  dynCharts.childComponents.add(chartPanel);
              }
              else if(chart.RecordType.Name == 'Box'){
                  Component.Apex.OutputPanel chartPanel = new Component.Apex.OutputPanel(styleClass=styleCls );
                  chartPanel.childComponents.add(new Component.ChartBox(chartName = chart.Name,chartHTMLId = chart.Name.replace(' ','') + 'Id')); 
                  dynCharts.childComponents.add(chartPanel);
              }else if(chart.RecordType.Name == 'Progress Bar'){
                   Component.Apex.OutputPanel chartPanel = new Component.Apex.OutputPanel(styleClass=styleCls );
                   chartPanel.childComponents.add(new Component.ChartProgress(chartName = chart.Name,chartHTMLId =chart.Name.replace(' ','') + 'Id')); 
                   dynCharts.childComponents.add(chartPanel);
              }else if(chart.RecordType.Name == 'Bar - Stacked'){
                   Component.Apex.OutputPanel chartPanel = new Component.Apex.OutputPanel(styleClass=styleCls );
                   chartPanel.childComponents.add(new Component.ChartBarStacked(chartName = chart.Name,chartHTMLId =chart.Name.replace(' ','') + 'Id')); 
                   dynCharts.childComponents.add(chartPanel);
              }
              else if(chart.RecordType.Name == 'Pie - Basic'){
                   Component.Apex.OutputPanel chartPanel = new Component.Apex.OutputPanel(styleClass=styleCls );
                   chartPanel.childComponents.add(new Component.ChartPieBasic(chartName = chart.Name,chartHTMLId =chart.Name.replace(' ','') + 'Id')); 
                   dynCharts.childComponents.add(chartPanel);
              }else if(chart.RecordType.Name == 'Gauge - Angular'){
                   Component.Apex.OutputPanel chartPanel = new Component.Apex.OutputPanel(styleClass=styleCls );
                   chartPanel.childComponents.add(new Component.ChartGaugeAngular(chartName = chart.Name,chartHTMLId =chart.Name.replace(' ','') + 'Id')); 
                   dynCharts.childComponents.add(chartPanel);
              }else if(chart.RecordType.Name == 'Funnel - Basic'){
                   Component.Apex.OutputPanel chartPanel = new Component.Apex.OutputPanel(styleClass=styleCls );
                   chartPanel.childComponents.add(new Component.ChartFunnelBasic(chartName = chart.Name,chartHTMLId =chart.Name.replace(' ','') + 'Id')); 
                   dynCharts.childComponents.add(chartPanel);
              }else if(chart.RecordType.Name == 'Basic Line'){
                   Component.Apex.OutputPanel chartPanel = new Component.Apex.OutputPanel(styleClass=styleCls );
                   chartPanel.childComponents.add(new Component.ChartLineBasic(chartName = chart.Name,chartHTMLId = chart.Name.replace(' ','') + 'Id')); 
                   dynCharts.childComponents.add(chartPanel);
              }else if(chart.RecordType.Name == 'Bar - Basic'){
                   Component.Apex.OutputPanel chartPanel = new Component.Apex.OutputPanel(styleClass=styleCls );
                   chartPanel.childComponents.add(new Component.ChartBasicBar(chartName = chart.Name,chartHTMLId = chart.Name.replace(' ','') + 'Id')); 
                   dynCharts.childComponents.add(chartPanel);
              }
              else if(chart.RecordType.Name == 'HeatMap'){
                   Component.Apex.OutputPanel chartPanel = new Component.Apex.OutputPanel(styleClass=styleCls );
                   chartPanel.childComponents.add(new Component.HeatMapBasic(chartName = chart.Name,chartHTMLId = chart.Name.replace(' ','') + 'Id')); 
                   dynCharts.childComponents.add(chartPanel);
              }
              
          }*/

          /*
          Component.Apex.OutputPanel chartPanel2 = new Component.Apex.OutputPanel();
          chartPanel2.childComponents.add(new Component.HeatMap()); 
          dynCharts.childComponents.add(chartPanel2);
          */
          
           
          Component.Apex.OutputPanel chartPanel2 = new Component.Apex.OutputPanel();
          chartPanel2.childComponents.add(new Component.gnt.map(chartName='GISMap', chartHTMLId='121' )); 
          dynCharts.childComponents.add(chartPanel2);
          
          
          
          return dynCharts;
     }
    
    /*
        This method is fetching charts ids from UserPreference custom setting (custom app specific).
    */
    /*public void loadChartData(){
        String tabName = Apexpages.currentPage().getParameters().get('t');
        Map<String, Object> userSelectedChartsMap = new  Map<String, Object>();
        PhaseConfig__C phaseConfig = [select Id,Abbreviation__c,TotalChartsAllowedPerRow__c 
                    from PhaseConfig__c where name =:tabName  limit 1];
        row = Integer.valueOf(phaseConfig.TotalChartsAllowedPerRow__c);
        UserPreferences__c uPref = UserPreferences__c.getValues(UserInfo.getUserId());
        String appName = uPref.ActiveAppName__c;        
        String selectedCharts = '';
        system.debug('appName ----'+appName );
        if(appName == 'StateasGrantor'){
            selectedCharts = uPref.GrantorPhaseCharts__c;            
        }else if(appName == 'StateasGrantee'){
            selectedCharts = uPref.GranteePhaseCharts__c;
        }else if(appName == 'Recipient'){
            selectedCharts = uPref.RecipientPhaseCharts__c;
        }
        system.debug('selectedCharts ----'+selectedCharts );
        List<String> chartIdList = new List<String>();       
        if(!String.isEmpty(selectedCharts)){
            chartIdList = selectedCharts.split(',');            
            List<ChartConfig__c> chartConfig = [select ChartPageURL__c,ChartID__c, Title__c,RecordType.Name,Name 
                from ChartConfig__c where ChartID__c in :chartIdList and active__c = true AND 
                    PhaseConfig__c = :phaseConfig.Id limit 3];
            
            Map<String, ChartConfig__c> chartIdToConfigMap = new Map<String, ChartConfig__c>();
            for(ChartConfig__c chart : chartConfig){
                chartIdToConfigMap.put(chart.ChartID__c, chart);
            }           
            if(chartConfig != null && chartConfig.size() > 0){
                for(String chartId : chartIdList){          
                    ChartConfig__c chartTobeAdded = chartIdToConfigMap.get(chartId);
                    if(chartTobeAdded != null){
                        charts.add(chartTobeAdded);
                    }
                }                               
            }
        }
        system.debug('charts----'+charts);
    }*/
}