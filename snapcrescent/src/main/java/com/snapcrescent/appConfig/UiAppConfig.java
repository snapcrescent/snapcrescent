package com.snapcrescent.appConfig;

import java.io.Serializable;

import lombok.Data;

@Data
public class UiAppConfig implements Serializable {

	private static final long serialVersionUID = -6497139748806438592L;

	private String configKey;
	private String configValue;
}
