import { Injectable } from '@nestjs/common';

@Injectable()
export class AppService {
  getTest(): string {
    return 'Hello World! 12321312';
  }

  getHello(): string {
    return 'Hello World! 555';
  }
}
