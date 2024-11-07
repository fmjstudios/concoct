<?php

declare (strict_types=1);

namespace App\Service;

use App\Exception\APIException;
use Exception;
use Herbert\Envato\Auth\Token;
use Herbert\EnvatoClient;
use Psr\Log\LoggerInterface;

/**
 * EnvatoAPIClient is a wrapper for the baileyherbert/envato package and the EnvatoClient contained within.
 * This class wraps the existing client to ensure the success of API calls on behalf of the existing client,
 * since Envato imposes dynamic rate-limits on its' API routes.
 */
class EnvatoAPIClient
{

    /**
     * @var EnvatoClient The Envato API client we're wrapping.
     */
    private EnvatoClient $client;

    /**
     * @var LoggerInterface A generic logger.
     */
    private LoggerInterface $logger;

    /**
     * @var string The Envato personal access token which is grabbed from the
     * ENVATO_TOKEN environment variable.
     */
    private string $token;

    public function __construct(
        LoggerInterface $logger,
        string          $token,
    )
    {
        $this->logger = $logger;
        try {
            $apiToken = new Token($token);
            $this->client = new EnvatoClient($apiToken);
        } catch (Exception $e) {
            $logger->error("could not create Envato API client: ", ['error' => $e]);
        }
    }

    /**
     * Retrieve the ID of the currently authenticated user.
     * @returns string
     */
    public function getUserId(): int
    {
        return $this->client->getUserId();
    }

    /**
     * Retrieve the username of the currently authenticated user. If t
     * @returns string
     * @throws APIException
     */
    public function getUserName(): string
    {
        $res = $this->client->user->username();

        if ($res->error) {
            $err = "could not create Envato API client";
            $this->logger->error($err, ['error' => $res->error]);
            throw new APIException($err);
        }

        return $res->results['username'];
    }
}
