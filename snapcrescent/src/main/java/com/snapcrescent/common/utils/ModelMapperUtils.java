package com.snapcrescent.common.utils;

import org.modelmapper.Converter;

import com.snapcrescent.common.utils.Constant.DbEnum;


public class ModelMapperUtils {
	
	public static Converter<String, String> getTruncator(int targetLength, String suffix) {
		return context -> context.getSource() == null ? null :  context.getSource().trim().length() > targetLength ? StringUtils.truncate(context.getSource(), targetLength) + suffix : StringUtils.truncate(context.getSource(), targetLength);
	}
	
	public static Converter<DbEnum, String> getDbEnumConvertor() {
		return context -> context.getSource() == null ? null :  context.getSource().getLabel();
	}
	

}
