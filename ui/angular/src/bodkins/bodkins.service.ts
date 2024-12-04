import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Bodkin } from "./bodkin";
import { environment } from "../environment/environment"
import { Observable } from 'rxjs';
//import { Observable, of } from "rxjs";
//import {catchError, tap, map} from 'rxjs/operators'

@Injectable({
  providedIn: 'root'
})
export class BodkinsService {

  constructor(private http: HttpClient) { }

  private httpOptions = {
    headers: new HttpHeaders({
      'Content-Type': 'application/json'
    })
  }

  private baseUrl = 'http://localhost:' + environment.bodkinsPort + '/bodkins'

  postBodkin(bodkin: Bodkin): Observable<Object> {
    console.log("post new bodkin at port " + environment.bodkinsPort)
    let url = this.baseUrl
    return this.http.post(url, bodkin, this.httpOptions);
  }

  listBodkins(): Observable<Object> {
    console.log("list bodkin at port " + environment.bodkinsPort)
    let url = this.baseUrl;
    return this.http.get(url, this.httpOptions);
  }
}
