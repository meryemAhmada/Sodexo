@IsTest
public class SPIRE_CTRL003CriteriaEditor_Test {

    @IsTest
    public static void getRuleEngine_test(){
        Map<String,SPIRE_CTRL003CriteriaEditor.FieldWrapper> fields = SPIRE_CTRL003CriteriaEditor.getFields('Opportunity' , false , '' , '');
        system.assert(fields.size() > 0);
    }
    
    

}