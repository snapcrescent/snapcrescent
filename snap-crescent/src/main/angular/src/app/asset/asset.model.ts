import { BaseUiBean } from "../core/models/base.model";

export class Asset extends BaseUiBean{
  assetType:number;
  favorite:boolean;
  thumbnail: Thumbnail;
  metadata:Metadata
  token:string;

  //Transient
  url:string;
}

export class Thumbnail extends BaseUiBean{
  name:string;
  url:string;
}

export class Metadata extends BaseUiBean{
  name:string
  base64EncodedPhoto:string
  mimeType:string
}

export let AssetType = {
    PHOTO: {
      id: 1,
      label: "Photo"
    },
    VIDEO: {
      id: 2,
      label: "Video"
    }
  };
