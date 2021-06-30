package com.codeinsight.snap_crescent.common.utils;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Objects;

import javax.persistence.TypedQuery;


public class SearchDAOHelper<T> {
	
	List<String> searchTokens = new ArrayList<String>();
	String searchValue = null;
	String[] skipValues = {"A", "IN", "AT", "THE", "OF", "THIS", "FOR", "UP", "IS", "TO" };
	    
	public String getSearchWhereStatement(String[] stringFields, 
			                              String[] numberFields,
			                              String searchString,
			                              boolean willSearchId) {
		
		if (StringUtils.isBlank(searchString) ||
		   ((stringFields == null || stringFields.length == 0) && 
			(numberFields == null || numberFields.length == 0))) {
			return "";
		}
		
		searchValue = searchString;
		
		HashMap<String,String> skipMap = new HashMap<String,String>();
		
		for (int i=0; i<skipValues.length; ++i) {
			skipMap.put(skipValues[i], skipValues[i]);
		}
	       
    	List<Long> itemIdList = new ArrayList<Long>();

        String[] searchData = searchValue.split("\\s");
        
        for (int i=0; i<searchData.length; ++i) {
        	try {
				itemIdList.add(Long.parseLong(searchData[i]));
			} catch(NumberFormatException nfe){
			    //skip the non-numeric fields
			}
			
        	//skip the size of word is less than 2 
        	if (searchData[i].length() < 2) continue;
        	
        	if (skipMap.get(searchData[i].toUpperCase()) == null) {
    		    searchTokens.add(searchData[i]);
        	}
        }
        
        //default the search data to the original value
        // Walter 05-28-13: removed, the searchValue is already used in the default search,
        // no need to have duplicates in the where clause
        /*
        if (searchTokens.size() == 0) {
        	searchTokens.add(searchValue);
        }
        */
        // Walter 05-28-13: verify that tokens doesn't contain just the searchValue
        // remove it if that's the case
        if ((searchTokens.size() == 1) && searchValue.equals(searchTokens.get(0))) {
        	searchTokens.clear();
        }
 		
		StringBuffer hql = new StringBuffer();
		
        hql.append(" AND ( ");
        
        if (stringFields != null) {
            for (int j=0; j<stringFields.length -1; j++){
       	        hql.append(stringFields[j]+" like :sname OR ");
            }
            
            if (stringFields.length > 0) {
            	hql.append(stringFields[stringFields.length - 1]+" like :sname ");
            }
        }
      	 
        if (willSearchId && (numberFields != null) && (numberFields.length > 0)  && (itemIdList.size() > 0)) {
         	int numberFieldslimit = (numberFields.length > 5 ? 5 : numberFields.length);

         	if (stringFields.length > 0) {
         		// need joiner with previous string fields
         		hql.append(" OR ");
         	}
         	
         	for (int j=0; j<numberFieldslimit; j++) {
            	 for (int k=0; k<itemIdList.size() - 1; ++k) {
            	     hql.append(numberFields[j]);
            	     hql.append(" = ");
            	     hql.append(itemIdList.get(k).longValue());
            	     hql.append(" OR ");
                 }
            	 
            	 // last - or only - one has no OR
            	 hql.append(numberFields[j]);
            	 hql.append(" = ");
            	 hql.append(itemIdList.get(itemIdList.size() -1).longValue());
            	 
            	 // unless there are more coming
            	 if ((j + 1) < numberFieldslimit) {
            		 hql.append(" OR ");
            	 }
             } 
        }

        if (searchTokens.size() > 0) {
        	hql.append(" OR ( ");
        }
        
		for (int tokenPos=0; tokenPos<searchTokens.size(); tokenPos++){
			if (tokenPos == 0) {
				hql.append( "(");
			} else {
			    hql.append(" AND ( ");
			}
		            
		    for (int j=0; j<stringFields.length-1; j++){
		         hql.append(stringFields[j]+" like :sname"+tokenPos + " OR ");
		    }
		    
		    // last - or only - one has no OR
		    if (stringFields.length > 0) {
		    	hql.append(stringFields[stringFields.length - 1]+" like :sname"+tokenPos + " ");
		    }
		    
		    hql.append(" ) ");
		}
		
		if (searchTokens.size() > 0) {
			hql.append(" ) ");
		}
        
        hql.append(" ) ");
        
        return hql.toString();
	}
		
	public void setSearchStringValue(TypedQuery<T> inQuery) {
		if (inQuery == null) return;

		inQuery.setParameter("sname", new String("%"+searchValue+"%"));

		for(int index=0;index<searchTokens.size();index++){
			inQuery.setParameter("sname"+index, new String("%" + searchTokens.get(index) + "%"));
		}
	}
	
	public boolean isCriteriaListIsEmpty(List<Long> list) {
		list.removeIf(Objects::isNull);
		return list.isEmpty();
	}
}
