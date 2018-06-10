public with sharing class GrantsGovApplicationForm {

/*
  @TestVisible private Id applicationId;
  @TestVisible private Id recordId;
  @TestVisible private String formName;
  
  @TestVisible private FormConfig formConfig;
  @TestVisible private Map<String, String> formNamespaces;
  @TestVisible private List<String> formAttachments = new List<String>();
  
  public GrantsGovApplicationForm(String appId, String rId, String fName){
    applicationId = appId;
    recordId = rId;
    formName = fName;
  }
  
  public void buildForm(Dom.Xmlnode formsNode, Dom.Document doc){
    setFormConfig();

    System.debug('***form config' + formConfig);

    if(formConfig == null){
      return;
    }
    
    Structure structure = formConfig.structure;
    List<FormField> formFields = structure.children;
    List<sObject> formRecords = getFormData(recordId, null, structure.objectName, formFields, null);
    if(formRecords == null){
      //return;
    }
   
   FormRoot formRootConfig = structure.root;
   
   Dom.Xmlnode rootNode = formsNode.addChildElement(formRootConfig.name, getNameSpace(formRootConfig.namespacePrefix), formRootConfig.namespacePrefix);
   if(formRootConfig.regNamespaces != null){
     for(String ns: formRootConfig.regNamespaces){
        rootNode.setNamespace(ns, getNameSpace(ns));
     }
   }
   if(formRootConfig.attributes != null){
     for(Attribute attribute: formRootConfig.attributes){
       String value = (attribute.type == 'fixed' ? attribute.value : '');
       rootNode.setAttributeNS(attribute.name, value, getNameSpace(attribute.namespacePrefix), null);
     }   
   }
   
   addFormFields(rootNode, doc, formRecords != null ? formRecords.get(0) :  null, structure.children);
                
   Dom.XmlNode[] childNodes = rootNode.getChildren();
   if(childNodes == null || childNodes.size() == 0){
    formsNode.removeChild(rootNode);
   }
  }
         
  private void addFormFields(Dom.Xmlnode node, Dom.Document doc, sObject formRecord, List<FormField> formFields){
     for(FormField fField: formFields){
      if(fField.children == null || fField.children.isEmpty()){
         String fieldValue = '';       
         if(fField.dataconfig != null){
            if(String.isNotBlank(fField.dataconfig.field)){
              Object rawValue = formRecord.get(fField.dataconfig.field);            
              fieldValue = getFormattedValue(rawValue, fField);
            }else if(fField.dataconfig.dataType == 'fixed'){
              fieldValue = getFormattedValue(null, fField);
            }
         }

         if(String.isNotBlank(fieldValue)){
           Dom.Xmlnode childNode = node.addChildElement(fField.name, getNameSpace(fField.namespacePrefix), fField.namespacePrefix);
           childNode.addTextNode(fieldValue);
            System.debug('fField.regNamespaces---->'+fField.regNamespaces);      
           if(fField.regNamespaces != null){
             for(String ns: fField.regNamespaces){
                childNode.setNamespace(ns, getNameSpace(ns));
             }
           }
           System.debug('fField.attributes---->'+fField.attributes);
           if(fField.attributes != null){
            System.debug('fField.attributes---->'+fField.attributes);
             for(Attribute attribute: fField.attributes){
               Object attValue = null;
               if(attribute.type == 'fixed'){
                 attValue = attribute.value;
               }else if(attribute.dataconfig != null && String.isNotBlank(attribute.dataconfig.field)){
                 attValue = formRecord.get(attribute.dataconfig.field);
               }
               
               if(attValue != null && String.isNotBlank(attValue+'')){
                childNode.setAttributeNS(attribute.name, attValue+'', getNameSpace(attribute.namespacePrefix), null);
               }
             }   
           }    
         }     
     }else if(fField.children != null && !fField.children.isEmpty()){
          FormFieldDataConfig dataconfig = fField.dataconfig;
          if(dataconfig != null && dataconfig.dataType == 'attachment'){
            addFormFieldAttachments(node, doc, fField);
            System.debug('dataconfig'+dataconfig+''+'dataconfig.dataType'+dataconfig.dataType);
          }else if(dataconfig != null && dataconfig.dataType == 'childRecords'){
            Id filter = (fField.dataconfig.filterType == 'application' ? applicationId : recordId);
            String filterColumn = (String.isNotBlank(fField.dataconfig.filterColumn) ? fField.dataconfig.filterColumn : null);
            List<String> additionalColumns = fField.dataconfig.rowConfigColumns;       
              List<sObject> formRecords = getFormData(filter, filterColumn, fField.dataconfig.objectName, fField.children, additionalColumns);
              if(formRecords == null)continue;
              if(fField.dataconfig.records == 'multi'){
                for(sObject obj:formRecords){
                  Dom.Xmlnode childNode = node.addChildElement(fField.name, getNameSpace(fField.namespacePrefix), fField.namespacePrefix);       
                    addFormFields(childNode, doc, obj, fField.children);
                    checkForChildRecords(childNode);
                }
              }else if(fField.dataconfig.records == 'select'){
                Dom.Xmlnode childNode = node.addChildElement(fField.name, getNameSpace(fField.namespacePrefix), fField.namespacePrefix);
                for(FormField childfField: fField.children){
                  if(childfField.children != null && childfField.dataconfig != null && childfField.dataconfig.rowConfigs != null){
                  Dom.Xmlnode childfFieldNode = childNode.addChildElement(childfField.name, getNameSpace(childfField.namespacePrefix), childfField.namespacePrefix);
                  
                  if(childfField.dataconfig.records == 'columnsum'){
                    //prepareColumnSumValues(childfFieldNode, doc, childfField.children, formRecords, childfField.dataconfig.rowConfigs);
                  }else{
                      sObject cFormRecord = getSelectedRecord(formRecords, childfField.dataconfig.rowConfigs);
                      if(cFormRecord != null){
                          addFormFields(childfFieldNode, doc, cFormRecord, childfField.children);
                      }
                  }
                  checkForChildRecords(childfFieldNode);
                  }
                }
              checkForChildRecords(childNode);
              }
         }else{
            Dom.Xmlnode childNode = node.addChildElement(fField.name, getNameSpace(fField.namespacePrefix), fField.namespacePrefix);       
              addFormFields(childNode, doc, formRecord, fField.children);
              checkForChildRecords(childNode);
          }
      }
     }
  }
  
  private class IntegrationException extends Exception{}
  
  private void prepareColumnSumValues(Dom.Xmlnode node, Dom.Document doc, List<FormField> formFields, List<sObject> formRecords, List<RowConfig> rowConfigs){
      for(FormField formField: formFields){ 
        if(formField.dataconfig != null && formField.dataconfig.field != null){
          Dom.Xmlnode childNode = node.addChildElement(formField.name, getNameSpace(formField.namespacePrefix), formField.namespacePrefix);
          Decimal columnValue = getColumnSumVaue(formRecords, formField.dataconfig.field, rowConfigs);
          if(columnValue != null){
              childNode.addTextNode(String.valueOf(columnValue));
          }
          checkForChildRecords(childNode);
        }
      }
  }

  private Decimal getColumnSumVaue(List<sObject> formRecords, String field, List<RowConfig> rowConfigs){
        Decimal value = 0;
    
    for(RowConfig rowConfig: rowConfigs){
      List<RowConfig> rowConfigList = new List<RowConfig>();
      rowConfigList.add(rowConfig);
      sObject record = getSelectedRecord(formRecords, rowConfigList);
       if(record != null && record.get(field) != null){
         value = value + Decimal.valueOf(record.get(field)+'');
       }
     }
    
    return value;    
  }
  
  private sObject getSelectedRecord(List<sObject> formRecords, List<RowConfig> rowConfigs){
    for(sObject formRecord: formRecords){
      boolean match = true;
     for(RowConfig rowConfig: rowConfigs){
       if(String.valueOf(rowConfig.value) != String.valueOf(formRecord.get(rowConfig.key))){
         match = false;
         break;
       }
     } 
     if(match){
       return formRecord;
     }
    }
    
    return null;
  }
  
  private void checkForChildRecords(Dom.Xmlnode childNode){
    Dom.XmlNode[] childNodes = childNode.getChildren();
    if(childNodes == null || childNodes.size() == 0){
      Dom.XmlNode parentNode = childNode.getParent();
      parentNode.removeChild(childNode);
    }
  }
  
  private void addFormFieldAttachments(Dom.Xmlnode node, Dom.Document doc, FormField fField){
    if(fField.dataconfig == null || fField.dataconfig.attachmentConfig == null 
       || fField.dataconfig.attachmentConfig.classificationCodes == null || fField.dataconfig.attachmentConfig.classificationCodes.isEmpty()){
      return;
    }
    
    List<String> classificationCodes = fField.dataconfig.attachmentConfig.classificationCodes;
//    List<GNT__AttachmentExtension__c> attachmentExts = [SELECT GNT__AttachmentId__c FROM GNT__AttachmentExtension__c WHERE GNT__ParentId__c = :recordId AND GNT__Classification__c = :classificationCodes];
    List<GNT__AttachmentExtension__c> attachmentExts = [SELECT GNT__Attachment__c FROM GNT__AttachmentExtension__c WHERE GNT__ParentId__c = :recordId AND GNT__Classification__c = :classificationCodes];
    if(attachmentExts != null && !attachmentExts.isEmpty()){
      List<Id> attIds = new List<Id>();
      for(GNT__AttachmentExtension__c attachmentExt: attachmentExts){
        //attIds.add(attachmentExt.GNT__AttachmentId__c);
        attIds.add(attachmentExt.GNT__Attachment__c);
      }
      
      List<Attachment> attachments = [SELECT Id, ContentType, Name, Body FROM Attachment WHERE Id = :attIds];
      Map<String, String> attachmentData = new Map<String, String>();
      Integer sequence = null;
      if(fField.dataconfig.sequenceStart != null){
        sequence = fField.dataconfig.sequenceStart;
      }
      for(Attachment att: attachments){
        Blob attBlob = Crypto.generateDigest('SHA1', att.body);
        
        String fileName = (att.Id+'_'+att.Name);
        String cid = ('CID_' + fileName).replace('.','_').replace(' ', '_');
        attachmentData.put('FileName', fileName);
        attachmentData.put('MimeType', (att.ContentType != null ? att.ContentType : 'application/octet-stream'));
        attachmentData.put('FileHref', cid);
        attachmentData.put('HashValue', EncodingUtil.base64Encode(attBlob));
        
        String fieldName = fField.name;
        if(sequence != null){
          fieldName = fieldName.replace('{sequence}', String.valueOf(sequence));
        }

        Dom.Xmlnode childNode = node.addChildElement(fieldName, getNameSpace(fField.namespacePrefix), fField.namespacePrefix);
        if(fField.children != null && fField.children.get(0).dataconfig == null){//TODO fix this
          FormField cfField = fField.children.get(0);
          
            String cfName = cfField.name;
            if(sequence != null){
              cfName = cfName.replace('{sequence}', String.valueOf(sequence));
            }
            
          Dom.Xmlnode cfNode = childNode.addChildElement(cfName, getNameSpace(cfField.namespacePrefix), cfField.namespacePrefix);
          addFormFieldAttachment(cfNode, doc, attachmentData, cfField.children);
        }else{
          addFormFieldAttachment(childNode, doc, attachmentData, fField.children);
        }
        
        formAttachments.add(att.Id + '~~' + cid);
        
        if(sequence != null){
           sequence++;          
        }
      }
      
    }
  }
  
  private void addFormFieldAttachment(Dom.Xmlnode node, Dom.Document doc, Map<String, String> formRecord, List<FormField> formFields){
    for(FormField fField: formFields){
      if(fField.children == null || fField.children.isEmpty()){
         String fieldValue = '';       
         if(fField.dataconfig != null && String.isNotBlank(fField.dataconfig.field)){
            fieldValue = formRecord.get(fField.dataconfig.field);
         }

         //if(String.isNotBlank(fieldValue)){
           Dom.Xmlnode childNode = node.addChildElement(fField.name, getNameSpace(fField.namespacePrefix), fField.namespacePrefix);
           if(String.isNotBlank(fieldValue)){
            childNode.addTextNode(fieldValue);
           }
                 
           if(fField.regNamespaces != null){
             for(String ns: fField.regNamespaces){
                childNode.setNamespace(ns, getNameSpace(ns));
             }
           }
           if(fField.attributes != null){
             for(Attribute attribute: fField.attributes){
               String attValue = '';
               if(attribute.type == 'fixed'){
                 attValue = attribute.value;
               }else if(attribute.dataconfig != null && String.isNotBlank(attribute.dataconfig.field)){
                 attValue = formRecord.get(attribute.dataconfig.field);
               }
               
               if(attValue != null && String.isNotBlank(attValue)){
                childNode.setAttributeNS(attribute.name, attValue, getNameSpace(attribute.namespacePrefix), null);
               }
             }   
           }    
         //}     
      }
    }
  }
  
  private String getFormattedValue(Object value, FormField fField){
      FormFieldDataConfig dataconfig = fField.dataconfig;
      String fieldType = dataconfig.dataType;

      if(fieldType == 'fixed' && String.isNotEmpty(dataconfig.value)){
        return String.isNotBlank(dataconfig.value) ?  dataconfig.value : '';        
      }

      String fieldValue = (value == null ? '' : (value + ''));
      if(String.isBlank(fieldValue) || String.isBlank(fieldType)){
        return fieldValue;
      }
      
      
        "state" - N
        "country" - N
        "amount" - N
      
      if(fieldType == 'list-split' && dataconfig.splitConfig != null){
        String delimiter = dataconfig.splitConfig.delimiter;
        Integer index = dataconfig.splitConfig.index;
        String[] values = fieldValue.split(delimiter);
        if(values != null && values.size() > index){
          fieldValue = values[index];
        }else{
          fieldValue = '';
        }
      }else if(fieldType == 'date'){
          DateTime tempDate = DateTime.valueOf(fieldValue);
          fieldValue = tempDate.format('YYYY-MM-dd');
      }else if(fieldType == 'list-translate' && dataconfig.rowConfigs != null && !dataconfig.rowConfigs.isEmpty()){        
        List<RowConfig> rowConfigs = dataconfig.rowConfigs;
        String translatedValue = '';
        for(RowConfig rowConfig: rowConfigs){
          if(rowConfig.key == fieldValue){
            translatedValue = rowConfig.value;
          }
        }
        
        fieldValue = translatedValue;
      }
      
      return fieldValue;
  }
  
  private String getNameSpace(String namespacePrefix){
        if(formNamespaces == null){
          formNamespaces = new Map<String, String>();
          List<FormNameSpace> namespaces = formConfig.structure.namespaces;
          for(FormNameSpace ns: namespaces){
            formNamespaces.put(ns.name, ns.value);
          }
        }
  
        return formNamespaces.get(namespacePrefix);       
  }
  
  private List<sObject> getFormData(Id filterId, String filterColumn, String objectName, List<FormField> formFields, List<String> additionalColumns){
    if(formFields == null || formFields.isEmpty()){
      return null;
    }
    
    String ns = AppUtils.getNamespacePrefix();
    String fieldQuery = '';
    Set<String> allFields = new Set<String>();
    setQueryFields(formFields, allFields);
    for(String fieldName:allFields){
       if(String.isNotBlank(fieldName)){
         fieldQuery += (fieldQuery != '' ? ', ' : '') + (ns + fieldName) ;
       }
    }
    
    if(additionalColumns != null){
      for(String additionalColumn: additionalColumns){
       if(String.isNotBlank(additionalColumn)){
         fieldQuery += (fieldQuery != '' ? ', ' : '') + (ns + additionalColumn) ;
       }
      }
    }
    
    if(String.isBlank(fieldQuery)){
      return null;
    }
    filterColumn = (String.isBlank(filterColumn) ? 'Id' : (ns + filterColumn) );
    String soql = 'SELECT ' + fieldQuery + ' FROM ' + ns + objectName + ' WHERE '+ filterColumn +' = \'' + filterId + '\'';
    System.debug('applicationId:' + applicationId + ' recordId:'+ recordId + 'formName: '+ formName +' >>>>>>>>>>>>>>>>SOQL>>>>>>>>' + soql);
    List<sObject> results = Database.query(soql);
    return results;
  }
  
  private void setQueryFields(List<FormField> formFields, Set<String> allFields){
    for(FormField formField:formFields){
      String fieldName = (formField.dataconfig != null ? formField.dataconfig.field : null);
       if(String.isNotBlank(fieldName) && !allFields.contains(fieldName)){
          allFields.add(fieldName);
       }
       
       if((formField.children != null && !formField.children.isEmpty()) 
          && (formField.dataconfig == null || (formField.dataconfig.dataType != 'attachment' && formField.dataconfig.dataType != 'childRecords') )
          ){
         setQueryFields(formField.children, allFields);
       }
       
    }
  }
  
  private void setFormConfig() {
    List<IntegrationFormConfig__c> integrationFormConfigs = [SELECT FormConfig__c FROM IntegrationFormConfig__c WHERE name =: formName AND IsActive__c = true];
    if(integrationFormConfigs != null && integrationFormConfigs.size() > 0){
      JSONParser parser = JSON.createParser(integrationFormConfigs.get(0).FormConfig__c);
      if(parser.nextToken() == JSONToken.START_OBJECT)
        formConfig = (GrantsGovApplicationForm.FormConfig)parser.readValueAs(GrantsGovApplicationForm.FormConfig.class);
    }
  }

  public List<String> getFormAttachments(){
    return formAttachments;
  }

  @TestVisible private class FormConfig {
      public String name;
      public Structure structure;
  }  
  
  @TestVisible private class Structure {
      public String objectName;
      public List<FormNameSpace> namespaces;
      public FormRoot root;
      public List<FormField> children;
  }
  
  @TestVisible private class FormRoot {
      public String name;
      public String namespacePrefix;
      public List<String> regNamespaces;
      public List<Attribute> attributes;
  }
  
  @TestVisible private class Attribute {
      public String name;
      public String value;
      public String type;
      public String namespacePrefix;
      public FormFieldDataConfig dataconfig;
  }
  
  @TestVisible private class FormNameSpace {
      public String name;
      public String value;
  }
  
  @TestVisible private class FormField {
      public String name;
      public String namespacePrefix;
      public List<Attribute> attributes;
      public FormFieldDataConfig dataconfig;
      public List<FormField> children;
      public FormFieldAttachmentConfig attachmentConfig;
      public List<String> regNamespaces;
  }
  
  @TestVisible private class FormFieldAttachmentConfig {
      List<String> classificationCodes;
  }
  
  @TestVisible private class FormFieldDataConfig {
      public String field;
      public String dataType;
      public String value;     

      public String objectName;
      public String records;
      public String filterType;
      public String filterColumn;
      public Integer sequenceStart;

      public List<RowConfig> rowConfigs;
      public List<String> rowConfigColumns;
      public DataSplitConfig splitConfig;
      public AttachmentConfig attachmentConfig;      
  }
  
  @TestVisible private class RowConfig{
    public String key;
    public String value;
  }
  
  @TestVisible private class DataSplitConfig{
    public String delimiter;
    public Integer index;
  }
  
  @TestVisible private class AttachmentConfig{
    public List<String> classificationCodes;
  }
  
*/}