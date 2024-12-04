import { Injectable } from "@angular/core";
import { BehaviorSubject } from "rxjs";

@Injectable({providedIn: 'root'})
export class BodkinsChangedService {
    private subject = new BehaviorSubject({})
    data$ = this.subject.asObservable();

    bodkinChanged(id: number) {
        this.subject.next(id);
    }
}
