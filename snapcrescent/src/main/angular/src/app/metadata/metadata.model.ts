import { BaseUiBean } from "../core/models/base.model";

export class Metadata extends BaseUiBean {
  name:string
  mimeType:string
  height: number
  width : number
  orientation: number
  duration : number
  durationString : string
}

