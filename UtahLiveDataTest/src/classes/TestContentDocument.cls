@isTest

private class TestContentDocument {

  private static testMethod void testCreate() {

    ContentVersion contentVersion_1 = new ContentVersion(

      Title = 'Penguins',

      PathOnClient = 'Penguins.jpg',

      VersionData = Blob.valueOf('Test Content'),

      IsMajorVersion = true

    );

    insert contentVersion_1;

    

    ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];

    List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

    System.assertEquals(documents.size(), 1);

    System.assertEquals(documents[0].Id, contentVersion_2.ContentDocumentId);

    System.assertEquals(documents[0].LatestPublishedVersionId, contentVersion_2.Id);

    System.assertEquals(documents[0].Title, contentVersion_2.Title);

  }

}