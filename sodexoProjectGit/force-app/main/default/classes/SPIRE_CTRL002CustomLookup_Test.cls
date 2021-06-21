@IsTest
public class SPIRE_CTRL002CustomLookup_Test {
    
    @IsTest
    public static void fetchRecords_test(){
        List<SPIRE_CTRL002CustomLookup.RecordsData> objects = SPIRE_CTRL002CustomLookup.fetchRecords('Opportunity');
        system.assert(objects.size() > 0);
    }
    
    @IsTest
    public static void getSelectedObj_test_1(){
        SPIRE_CTRL002CustomLookup.RecordsData objectRecord = SPIRE_CTRL002CustomLookup.getSelectedObj('Opportunity');
        system.assertEquals(objectRecord.label , 'Opportunity');
        system.assertEquals(objectRecord.value , 'Opportunity');
    }
    
}