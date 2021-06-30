package com.codeinsight.snap_crescent.common.utils;

import java.io.IOException;

import com.fasterxml.jackson.core.JsonGenerationException;
import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.ObjectMapper;

public class JsonUtils {

	private static ObjectMapper objectMapper = new ObjectMapper();;
	
	static {
		objectMapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
	}

	public static String writeJsonString(Object object) throws JsonGenerationException, JsonMappingException, IOException {
		return objectMapper.writeValueAsString(object);
	}

	public static <T> T getObjectFromJson(String jsonString, TypeReference<T> ref)
			throws JsonParseException, JsonMappingException, IOException {
		return objectMapper.readValue(jsonString, ref);
	}
}
