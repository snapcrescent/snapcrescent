package com.codeinsight.snap_crescent.location;

import com.codeinsight.snap_crescent.common.beans.BaseUiBean;

import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = false)
public class UiLocation extends BaseUiBean {

	private static final long serialVersionUID = -5153885822493234594L;

	private Double longitude;
	private Double latitude;
	private String country;
	private String state;
	private String city;
	private String town;
	private String postcode;

}
