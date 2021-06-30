package com.codeinsight.snap_crescent.common.utils;

import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;

import org.apache.commons.beanutils.BeanUtils;
import org.springframework.stereotype.Component;

import com.codeinsight.snap_crescent.common.annotations.XssSafe;


@Component
public class BeanXSSCleaner {
	
	private String htmlRegex = "<[^>]*>";
	private String alertRegex = "javascript:alert\\(.*\\)";
	private List<Pattern> patterns = new ArrayList<>();
	
	public BeanXSSCleaner() {
		
		patterns.add(Pattern.compile("<[^>]*>", Pattern.CASE_INSENSITIVE));
		patterns.add(Pattern.compile("<a href=\\\"#\\\">HTML Link</a>", Pattern.CASE_INSENSITIVE));
		patterns.add(Pattern.compile("<script>(.*?)</script>", Pattern.CASE_INSENSITIVE));
		patterns.add(Pattern.compile("src[\r\n]*=[\r\n]*\\\'(.*?)\\\'", Pattern.CASE_INSENSITIVE | Pattern.MULTILINE | Pattern.DOTALL));
		patterns.add(Pattern.compile("src[\r\n]*=[\r\n]*\\\"(.*?)\\\"", Pattern.CASE_INSENSITIVE | Pattern.MULTILINE | Pattern.DOTALL));
		patterns.add(Pattern.compile("</script>", Pattern.CASE_INSENSITIVE));
		patterns.add(Pattern.compile("<script(.*?)>", Pattern.CASE_INSENSITIVE | Pattern.MULTILINE | Pattern.DOTALL));
		patterns.add(Pattern.compile("eval\\((.*?)\\)", Pattern.CASE_INSENSITIVE | Pattern.MULTILINE | Pattern.DOTALL));
		patterns.add(Pattern.compile("expression\\((.*?)\\)", Pattern.CASE_INSENSITIVE | Pattern.MULTILINE | Pattern.DOTALL));
		patterns.add(Pattern.compile("javascript:", Pattern.CASE_INSENSITIVE));
		patterns.add(Pattern.compile("vbscript:", Pattern.CASE_INSENSITIVE));
		patterns.add(Pattern.compile("onload(.*?)=", Pattern.CASE_INSENSITIVE | Pattern.MULTILINE | Pattern.DOTALL));
		
	}
	
	public void cleanBean(Object object)
	{
		if(object == null)
		{
		return;	
		}
		
		Field[] fields = object.getClass().getDeclaredFields();
		
		for (Field field : fields) {
			if(field.isAnnotationPresent(XssSafe.class) && field.getType().equals(String.class))
				{
				String fieldname =  field.getName();
				
				  try {
					 String value = BeanUtils.getProperty(object, fieldname);
					 
					 value = stripXSS(value);

					 BeanUtils.setProperty(object, fieldname, value);
					 
					} catch (IllegalAccessException | InvocationTargetException | NoSuchMethodException e) {
						e.printStackTrace();
					}
				}
		}
	}
	
	public String cleanEmailBody(String emailBody)
	{
		return emailBody.replaceAll(alertRegex, "javascript:void()");
	}
	
  private  String stripXSS(String value) {
        if (value != null) {
            //value = ESAPI.encoder().canonicalize(value);

            // Avoid null characters
            value = value.replaceAll("\0", "");

            // Remove all sections that match a pattern
            for (Pattern scriptPattern : patterns){
                value = scriptPattern.matcher(value).replaceAll("");
            }
            
            value = value.replaceAll(htmlRegex, "");
        }
        return value;
    }
}
