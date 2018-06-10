public with sharing class QueueListView {
  public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}

    public QueueListView(ApexPages.StandardController controller) {
            listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
            GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper('Type','Queue',true);
            listDefaultValues.add(dv);
    }

}