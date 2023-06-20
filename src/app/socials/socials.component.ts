import {Component, OnInit} from '@angular/core';
import {HttpClient} from "@angular/common/http";
import {environment} from "../../environments/environment";
import {Social} from "../backend/Social";
import {BackendService} from "../backend/backend.service";

@Component({
  selector: 'app-socials',
  templateUrl: './socials.component.html',
  styleUrls: ['./socials.component.css']
})
export class SocialsComponent implements OnInit {
  title = 'Socials'
  socialCollection: Social[] = [
    {
      name: 'henk',
      href: 'google.nl',
      target: '_blank'
    },
    {
      name: 'henk 2',
      href: 'google.nl',
      target: '_blank'
    },
  ];

  ngOnInit() {
    this.backendService.getSocialCollection().subscribe(value => {
      this.socialCollection = value;
    });
  }

  constructor(
    private http: HttpClient,
    private backendService: BackendService
  ) {}
}
