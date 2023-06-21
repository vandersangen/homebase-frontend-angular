import { Component } from '@angular/core';
import {BackendService} from "../backend/backend.service";

@Component({
  selector: 'app-introduction',
  templateUrl: './introduction.component.html',
  styleUrls: ['./introduction..component.css']
})
export class IntroductionComponent {
  constructor(private backendService: BackendService) {}

  get introductionText() {
    return this.backendService.introductionText;
  }
}
