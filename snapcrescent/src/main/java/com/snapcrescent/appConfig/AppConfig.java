package com.snapcrescent.appConfig;

import java.io.Serializable;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;

import lombok.Data;

@Entity
@Data
public class AppConfig implements Serializable {

	private static final long serialVersionUID = -6497139748806438592L;

	@Id
	private long id;
	
	private String configKey;
	private String configValue;

}
