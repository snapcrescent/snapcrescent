package com.codeinsight.snap_crescent.common.utils;

public class StringUtils extends org.apache.commons.lang3.StringUtils {

	public static String getBeautifiedCouponCode(String couponCode) {
		StringBuffer stringBuffer = new StringBuffer();
		String[] tokens = couponCode.split("(?<=\\G.{" + 4 + "})");

		boolean isFirstToken = true;
		for (String token : tokens) {
			if (isFirstToken == false) {
				stringBuffer.append("-");
			}
			stringBuffer.append(token);
			isFirstToken = false;
		}

		return stringBuffer.toString();
	}

	public static String replaceString(String string, String replace, String replaceWith) {
		return string.replace(replace, replaceWith);
	}

	
}
