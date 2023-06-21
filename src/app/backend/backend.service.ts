import {Injectable} from '@angular/core';
import {Social} from "./Social";
import {environment} from "../../environments/environment";
import {HttpClient} from "@angular/common/http";

@Injectable({
  providedIn: 'root'
})
export class BackendService {
  introductionText = '...';
  socialCollection: Social[] = [{name: 'sample', href: 'blank.org', target: '_blank'}];

  constructor(private http: HttpClient) {
    this.getSocialCollection();
    this.getIntroduction();
  }

  getSocialCollection() {
    const endpoint = environment.API_URL + '/api/socials';
    this.http.get<Social[]>(endpoint).subscribe(value => {
      this.socialCollection = value;
    });
  }

  private getIntroduction() {
    const endpoint = environment.API_URL + '/api/introduction';
    this.http.get<string>(endpoint).subscribe(value => {
      this.introductionText = value;
    });
  }
}
