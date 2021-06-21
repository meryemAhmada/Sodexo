@IsTest
public class SPIRE_CTRL001FieldSelection_Test {
    
    @IsTest
    public static void test(){
        Map<String,SPIRE_CTRL001FieldSelection.FieldWrapper> fields = SPIRE_CTRL001FieldSelection.getFields('Opportunity');
        system.assert(fields.size() > 0);
    }
    
}