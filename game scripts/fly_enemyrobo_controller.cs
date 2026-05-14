using UnityEngine;
using UnityEngine.AI;

/* Controls the enemy AI using an explicit finite state machine. */

public class fly_enemyrobo_controller : MonoBehaviour
{
    private enum EnemyState
    {
        Idle,
        Patrol,
        Chase,
        Attack,
        Dead
    }

    public float lookRadius = 10f;
    public Transform enemy;
    public float playRate = 1f;
    public AudioSource attacksource;
    public LayerMask whatIsPlayer;
    public float sightRange;
    public float attackRange;
    public bool playerInSightRange;
    public bool playerInAttackRange;
    public ParticleSystem gunflash;
    public string currentStateName;

    private Transform target;
    private NavMeshAgent agent;
    private AudioSource audioSource;
    private Vector3 temp;
    private EnemyState currentState = EnemyState.Idle;
    private float nextPlayTime;

    private void Start()
    {
        agent = GetComponent<NavMeshAgent>();
        enemy = GetComponent<Transform>();
        audioSource = GetComponent<AudioSource>();
        temp = enemy.position;
        if (audioSource != null)
        {
            audioSource.Play();
        }
        TransitionToState(EnemyState.Idle);
    }

    private void Update()
    {
        ResolveTarget();

        fly_enemy_health_script healthScript = enemy.GetComponent<fly_enemy_health_script>();
        if (healthScript == null)
        {
            return;
        }

        if (healthScript.health <= 0f)
        {
            TransitionToState(EnemyState.Dead);
            return;
        }

        if (target == null)
        {
            TransitionToState(EnemyState.Idle);
            return;
        }

        playerInSightRange = Physics.CheckSphere(transform.position, sightRange, whatIsPlayer);
        playerInAttackRange = Physics.CheckSphere(transform.position, attackRange, whatIsPlayer);

        EnemyState nextState = DetermineState(healthScript);
        TransitionToState(nextState);
        TickState();
    }

    private void ResolveTarget()
    {
        GameObject playerObject = GameObject.FindGameObjectWithTag("Player");
        target = playerObject != null ? playerObject.transform : null;
    }

    private EnemyState DetermineState(fly_enemy_health_script healthScript)
    {
        if (healthScript.health <= 0f)
        {
            return EnemyState.Dead;
        }

        if (playerInAttackRange && playerInSightRange)
        {
            return EnemyState.Attack;
        }

        if (playerInSightRange || healthScript.enemy_hurting)
        {
            return EnemyState.Chase;
        }

        float distanceFromSpawn = Vector3.Distance(enemy.position, temp);
        if (distanceFromSpawn > 1.5f)
        {
            return EnemyState.Patrol;
        }

        return EnemyState.Idle;
    }

    private void TickState()
    {
        switch (currentState)
        {
            case EnemyState.Idle:
                TickIdle();
                break;
            case EnemyState.Patrol:
                TickPatrol();
                break;
            case EnemyState.Chase:
                TickChase();
                break;
            case EnemyState.Attack:
                TickAttack();
                break;
            case EnemyState.Dead:
                TickDead();
                break;
        }
    }

    private void TickIdle()
    {
        agent.ResetPath();
        StopGunflash();
    }

    private void TickPatrol()
    {
        agent.SetDestination(temp);
        StopGunflash();

        if (Vector3.Distance(enemy.position, temp) <= 1.5f)
        {
            TransitionToState(EnemyState.Idle);
        }
    }

    private void TickChase()
    {
        agent.SetDestination(target.position);
        StopGunflash();
    }

    private void TickAttack()
    {
        agent.ResetPath();
        FaceTarget();

        if (Time.time < nextPlayTime)
        {
            return;
        }

        target_enemy targetEnemy = agent.GetComponent<target_enemy>();
        if (targetEnemy != null)
        {
            targetEnemy.enemy_targeting();
        }

        if (gunflash != null)
        {
            gunflash.Play();
        }

        if (attacksource != null)
        {
            attacksource.Play();
        }
        nextPlayTime = Time.time + playRate;
    }

    private void TickDead()
    {
        agent.ResetPath();
        StopGunflash();
    }

    private void TransitionToState(EnemyState nextState)
    {
        if (currentState == nextState)
        {
            currentStateName = currentState.ToString();
            return;
        }

        currentState = nextState;
        currentStateName = currentState.ToString();
    }

    private void FaceTarget()
    {
        if (target == null)
        {
            return;
        }

        Vector3 direction = (target.position - transform.position).normalized;
        Quaternion lookRotation = Quaternion.LookRotation(new Vector3(direction.x, 0f, direction.z));
        transform.rotation = Quaternion.Slerp(transform.rotation, lookRotation, Time.deltaTime * 5f);
    }

    private void StopGunflash()
    {
        if (gunflash != null && gunflash.isPlaying)
        {
            gunflash.Stop();
        }
    }

    private void OnDrawGizmosSelected()
    {
        Gizmos.color = Color.red;
        Gizmos.DrawWireSphere(transform.position, lookRadius);
        Gizmos.color = Color.red;
        Gizmos.DrawWireSphere(transform.position, attackRange);
        Gizmos.color = Color.yellow;
        Gizmos.DrawWireSphere(transform.position, sightRange);
    }
}
