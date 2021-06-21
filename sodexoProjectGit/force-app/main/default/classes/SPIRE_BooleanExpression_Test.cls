@isTest
public class SPIRE_BooleanExpression_Test {
    @IsTest
    public static void eval_test(){
        System.assert(SPIRE_BooleanExpression.eval('TRUE'));
        System.assert(SPIRE_BooleanExpression.eval('TRUE OR FALSE'));
        System.assert(SPIRE_BooleanExpression.eval('TRUE OR TRUE'));
        System.assert(SPIRE_BooleanExpression.eval('TRUE OR (TRUE AND FALSE)'));
        System.assert(SPIRE_BooleanExpression.eval('TRUE OR (TRUE AND FALSE AND TRUE OR TRUE)'));
        System.assert(SPIRE_BooleanExpression.eval('TRUE OR (TRUE AND FALSE AND (TRUE OR FALSE))'));
        System.assert(SPIRE_BooleanExpression.eval('TRUE OR (TRUE OR (FALSE AND (TRUE OR FALSE)))'));
        System.assert(SPIRE_BooleanExpression.eval('(FALSE OR ((TRUE OR FALSE) AND (TRUE OR FALSE)))'));
        
        System.assert(!SPIRE_BooleanExpression.eval('FALSE'));
        System.assert(!SPIRE_BooleanExpression.eval('TRUE AND FALSE'));
        System.assert(!SPIRE_BooleanExpression.eval('FALSE AND FALSE'));
        System.assert(!SPIRE_BooleanExpression.eval('TRUE AND (TRUE AND FALSE)'));
        System.assert(!SPIRE_BooleanExpression.eval('FALSE AND (TRUE AND FALSE AND TRUE OR TRUE)'));
        System.assert(!SPIRE_BooleanExpression.eval('TRUE AND (TRUE AND FALSE AND (TRUE OR FALSE))'));
        System.assert(!SPIRE_BooleanExpression.eval('TRUE AND (TRUE AND (FALSE AND (TRUE OR FALSE)))'));
        System.assert(!SPIRE_BooleanExpression.eval('(FALSE AND ((TRUE OR FALSE) AND (TRUE OR FALSE)))'));
        System.assert(SPIRE_BooleanExpression.evalWithThrowException('TRUE OR FALSE'));
    }
}