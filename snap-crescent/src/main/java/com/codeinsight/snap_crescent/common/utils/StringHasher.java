package com.codeinsight.snap_crescent.common.utils;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

public class StringHasher {

	public static String getBCrpytHash(String source) throws Exception {
		try {
			PasswordEncoder encoder = new BCryptPasswordEncoder();
			return encoder.encode(source);
		} catch (Exception e) {
			throw new Exception();
		}
	}

}
