import { getConnections, wrapConn } from './utils';

let db, teardown, app;
const objs = {};
describe('scheduled jobs', () => {
  beforeAll(async () => {
    ({ db, teardown } = await getConnections());
    app = wrapConn(db, 'app_jobs');
  });
  afterAll(async () => {
    await teardown();
  });
  it('schedule jobs by cron', async () => {
    objs.scheduled1 = await app.insertOne(
      'scheduled_jobs',
      {
        task_identifier: 'my_job',
        schedule_info: {
          hour: Array.from({ length: 23 }, Number.call, (i) => i),
          minute: [0, 15, 30, 45],
          dayOfWeek: Array.from({ length: 6 }, Number.call, (i) => i)
        }
      },
      {
        schedule_info: 'json'
      }
    );
  });
  it('schedule jobs by rule', async () => {
    // every minute starting in 10 seconds for 3 minutes
    const start = new Date(Date.now() + 10000); // 10 seconds
    const end = new Date(start.getTime() + 180000); // 3 minutes
    objs.scheduled2 = await app.insertOne(
      'scheduled_jobs',
      {
        task_identifier: 'my_job',
        payload: {
          just: 'run it'
        },
        schedule_info: {
          start,
          end,
          rule: '*/1 * * * *'
        }
      },
      {
        schedule_info: 'json'
      }
    );
  });
  it('schedule jobs', async () => {
    const [result] = await app.callAny('run_scheduled_job', {
      id: objs.scheduled2.id
    });
    const { queue_name, run_at, created_at, updated_at, ...obj } = result;
    expect(obj).toMatchSnapshot();
  });
});
