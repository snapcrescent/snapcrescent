package com.codeinsight.snap_crescent.location;

import javax.persistence.Entity;
import javax.persistence.Table;

import com.codeinsight.snap_crescent.common.BaseEntity;

import lombok.Data;
import lombok.EqualsAndHashCode;

@Entity
@Table(name = "location")
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
