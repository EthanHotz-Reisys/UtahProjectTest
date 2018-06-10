public with sharing class FiscalYearHelper {
    
    public static Integer getFiscalYear(Date currentDate){
        Integer fiscalYear;
        if (currentDate.month() > 6){
            fiscalYear = currentDate.year() + 1;
        } else{
            fiscalYear = currentDate.year();
        }
        return fiscalYear;
    }
    
    public static Integer getFiscalYearShort(Date currentDate){
        Integer year = getFiscalYear(currentDate);
        String yearString = String.valueOf(year).Right(2);
        Integer fiscalYear = Integer.valueOf(yearString);
        return fiscalYear;
    }
}