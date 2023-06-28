package com.snapcrescent.location;

import jakarta.persistence.Entity;

import com.snapcrescent.common.BaseEntity;

import lombok.Data;
import lombok.EqualsAndHashCode;

@Entity
@Data
@EqualsAndHashCode(callSuper = false)
public class Location extends BaseEntity {

	private static final long serialVersionUID = -5153885822493234594L;

	private Double longitude;
	private Double latitude;
	private String country;
	private String state;
	private String city;
	private String town;
	private String postcode;

}
